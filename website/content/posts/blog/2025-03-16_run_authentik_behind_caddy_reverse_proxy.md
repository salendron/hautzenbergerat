---
title: "How to run Athentik behind a Caddy Reverse Proxy"
date: 2025-03-16T10:00:25Z
draft: false
tags: ["blog", "howto", "authentik", "docker", "dockercompose", "authentication", "devops"]
---
[Authentik](https://goauthentik.io/) is a self-hosted, open source identity provider, which I use to controll access to most of my homemade services. It is easy to use and easy to maintain, but setting it up within my go-to container setup wasn't as easy as I thought. 

I write this post only to save myself time in the future, if I have to do this again. So, if you you read this and think "oh, thank you Captain Obvious! Of course you have to do it that way!", just be sure that I am aware of the fact that this is very obvious, but if you are like me these small details can cost you hours before realizing that the solution is that simple.

## The Setup
So what is the problem? I have docker running on a linux server, which I use to run several services in easy to maintain containers. The server has a public IP, so I can reach these services from wherever I want. 
To map spcific services to dedicated domains, I use [Caddy](https://caddyserver.com/docs/install#docker), which I also run within a Docker container.
Now I wanted to run Authentik within this setup and also map it to a specific domain using Caddy, but *SUPRISE!* it did not work at all.

## How to make it work
The thing is that caddy for some reason is not able to map the server service just by adding the service to the caddy network and adding the label for the domain we want to map it to. Futhermore I want all other services of Authentik (Postgres, Redis, the workers) to be hidden from the outside world.
So here is what I did: First I followed the [Authentik Docker Setup Tutorial](https://docs.goauthentik.io/docs/install-config/install/docker-compose), but before starting the services, I made some changes to docker-compose.yaml to make it work within my setup. 

First of all I added a new network called *auth* and another one called *caddy*. The *auth* network will be connected to all services, so they could communicate with each other and of course we set it to *external: false*.

```YAML
networks:
  auth:
    external: false
  caddy:
    external: true
```

Now, as mentioned, I added all services to the *auth* network and the server service to the *auth* and *caddy* network, so I can map this service to a domain.

```YAML
networks:
      - caddy
      - auth
```

After doing so I faced strange HTTPS-Problems, which could be solved by adding some labels to the server service to tell Caddy how to handle HTTPS fot this service. Of course, I also set the *caddy* label to tell Caddy which domain to use for this service.

```YAML
labels:
      caddy: your.great-domain.com
      caddy.reverse_proxy: "{{upstreams https 9443}}"
      caddy.reverse_proxy.transport: http
      caddy.reverse_proxy.transport.tls_insecure_skip_verify:
```

And that's it. It is that simple, if you know that you have to do this. If you don't know that, it will cost you hours of your life. So maybe you've found this, because you had the same problem as I had and it saved you a lot of time.

Here is my whole docker-compose.yaml as a complete example.

```YAML
services:
  postgresql:
    image: docker.io/library/postgres:16-alpine
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
      start_period: 20s
      interval: 30s
      retries: 5
      timeout: 5s
    volumes:
      - database:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: ${PG_PASS:?database password required}
      POSTGRES_USER: ${PG_USER:-authentik}
      POSTGRES_DB: ${PG_DB:-authentik}
    env_file:
      - .env
    networks:
      - auth
  redis:
    image: docker.io/library/redis:alpine
    command: --save 60 1 --loglevel warning
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "redis-cli ping | grep PONG"]
      start_period: 20s
      interval: 30s
      retries: 5
      timeout: 3s
    volumes:
      - redis:/data
    networks:
      - auth
  server:
    image: ${AUTHENTIK_IMAGE:-ghcr.io/goauthentik/server}:${AUTHENTIK_TAG:-2024.6.4}
    restart: unless-stopped
    command: server
    environment:
      AUTHENTIK_REDIS__HOST: redis
      AUTHENTIK_POSTGRESQL__HOST: postgresql
      AUTHENTIK_POSTGRESQL__USER: ${PG_USER:-authentik}
      AUTHENTIK_POSTGRESQL__NAME: ${PG_DB:-authentik}
      AUTHENTIK_POSTGRESQL__PASSWORD: ${PG_PASS}
    volumes:
      - ./media:/media
      - ./custom-templates:/templates
    env_file:
      - .env
    ports:
      - "${COMPOSE_PORT_HTTP:-9000}:9000"
      - "${COMPOSE_PORT_HTTPS:-9443}:9443"
    depends_on:
      - postgresql
      - redis
    networks:
      - caddy
      - auth
    labels:
      caddy: your.great-domain.com
      caddy.reverse_proxy: "{{upstreams https 9443}}"
      caddy.reverse_proxy.transport: http
      caddy.reverse_proxy.transport.tls_insecure_skip_verify:
  worker:
    image: ${AUTHENTIK_IMAGE:-ghcr.io/goauthentik/server}:${AUTHENTIK_TAG:-2024.6.4}
    restart: unless-stopped
    command: worker
    environment:
      AUTHENTIK_REDIS__HOST: redis
      AUTHENTIK_POSTGRESQL__HOST: postgresql
      AUTHENTIK_POSTGRESQL__USER: ${PG_USER:-authentik}
      AUTHENTIK_POSTGRESQL__NAME: ${PG_DB:-authentik}
      AUTHENTIK_POSTGRESQL__PASSWORD: ${PG_PASS}
    user: root
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./media:/media
      - ./certs:/certs
      - ./custom-templates:/templates
    env_file:
      - .env
    depends_on:
      - postgresql
      - redis
    networks:
      - auth

networks:
  auth:
    external: false
  caddy:
    external: true

volumes:
  database:
    driver: local
  redis:
    driver: local                 
```