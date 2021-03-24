---
title: "How to run PostgreSQL on Docker"
date: 2021-03-24T18:35:25Z
draft: false
tags: ["blog", "howto", "docker", "postgresql", "database", "sql", "devops"]
---
In this how to I will show how to setup a PostgreSQL server on docker, including how to persist data outside of the container, and also how to run PGAdmin in a container as well. 
In this example I asume that you've already got Docker running on your server, if not, set this up first.

## Install PostgreSQL
By default the PostgreSQL container is configured to save its data to /var/lib/postgresql/data inside of the container. So if we delete the container, all data will be lost. To prevent this, we'll need to create a directory ouside of the container, which won't be deleted with the container, and then mount this directoy into the container, so PostgreSQL has a persistent place to save its data to.

```
mkdir -p /<path-on-your-server>/pgdata
```

### Run PostgreSQL
Now we can simply run PostgreSQL in docker and mount the directory to /var/lib/postgresql/data inside the container, so PostgreSQL will use our persistent directory.

```
docker run \
  -d \
  --name postgresql-container \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=somePassword \
  -v /<path-on-your-server>/pgdata:/var/lib/postgresql/data \
  postgres
```

We simply call our container "postgresql-container" (--name), export its default path 5432 (-p), set our password for the postgres user (-e POSTGRES_PASSWORD=<your-password-here>) and also map our local data directory to the path of the PostgreSQL default data directory in the container (-v /<path-on-your-server>/pgdata:/var/lib/postgresql/data). 
And that's it, we have a running PostgreSQL serve on docker, which we can access from the outside on port 5432.

## Run PGAdmin
PGAdmin is a widely used, OpenSource administration client for PostgreSQL and the best thing about it is, that you can use it in your browser, if you simply run it in a Docker container.
This is as simple as running the following command to deploy a PGAdmin container.

```
docker run -d -p 5050:5050 thajeztah/pgadmin4 
```

If you want to run PGAdmin on a RaspberryPi, or any other arm-based system, you need to use a different container image. This one works well for me.

```
docker run -d -p 5050:5050 biarms/pgadmin4 
```

After the container booted successfully, check container logs, because this may take some time, we can simply use a browser and navigate to http://your-server-address:5050, add our PostgreSQL server there and we are ready to go.

