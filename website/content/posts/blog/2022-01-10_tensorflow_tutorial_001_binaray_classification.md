---
title: "Simple binary classification with Tensorflow and Keras"
date: 2022-01-10T19:00:25Z
draft: false
tags: ["blog", "howto", "python", "tensorflow", "ml", "maschine learning", "keras"]
---
This is the first of - hopefully - a lot of Tensorflow/Keras tutorials I will write on this blog. In this first - very simple - example I will demonstrate how to use Tensorflow and Keras to train and use a model to predict if an IMDB movie review is positiv or negative. We will use the IMDB dataset for this, prepare the training data, so we can use it to train the model, and finally make predictions on data the model has never seen before. 

## Prequesites
I assume that you have basic knowledge in Python and also that you have installed Tensorflow correctly. If you don't, please do that first. The Tensorflow website has great tutorials on how to setup Tensorflow on your operating system. Also I am currently using Tensorflow version 2.7.0, so all examples were also developed and tested using this version. They will most likely also work on newer version, but if you run into any problems you might have to adapt the examples a little bit to make them work on the version you are using. 

## The training data
First of all we have to load the training data. We will use the IMDB movie review dataset, which we can simply import like this:
```python
from tensorflow.keras.datasets import imdb
```

The dataset consists of 25.000 reviews for training and 25.000 reviews for testing. It also contains a label for each review, which is telling us if the review is positive or negative. So we have 4 lists with 25.000 entries. Two of them containing the review text and the other two contain the label, positive or negative, for each review at the same index. This is why we use a binary classification here, we only have to predict if it is positive or not, 1 or 0. Now let's load the data into the four lists we were just talking about, but we will use only the 10000 most frequent used words, because words that are used not often, like once or twice, do not help us to classify the reviews. 
```python
NUM_WORDS = 10000
(train_data, trains_labels), (test_data, test_labels) = imdb.load_data(num_words=NUM_WORDS)
```

Tensorflow works best with numbers and therefor we have to find a way how we can represent the review texts in a numeric form. One way of doing this vectorization. That means that we will transform each review into a list of numbers which is exactly as long as the amount of words we expect, in this case NUM_WORDS=10000. We first fill it with zeros and then we write a 1 on each index of a word that occured in a certain review.
This will result in a list of lists, one for each review, filled with zeros and ones, but only if the word at this index exists. So let's implement a function to do that for us and then vectorize our train and test data.
```python
def vectorize__sequences(sequences, dimension):
    results = np.zeros((len(sequences), dimension))

    for i, sequence in enumerate(sequences):
        for j in sequence:
            results[i, j] = 1.

    return results

x_train = vectorize__sequences(train_data, NUM_WORDS)
x_test = vectorize__sequences(test_data, NUM_WORDS)
```
You noticed that this way we loose all information about how often a word appears, we only set a 1 if it exists at all, and also about where this wird appears in the review. The cool thing is, we do not need that information to predict if this review is positive or negative. We just need to know which words are in a review and which words aren't.


Now we also need to convert our labels to numpy arrays of type float32 so we can use them to train and validate our model.
```python
import numpy as np

y_train = np.asarray(trains_labels).astype("float32")
y_test = np.asarray(test_labels).astype("float32")
```

Lastly we also take a portion of the training data, which we will later on use to validate our model. The reason why we take that data awaay form training is that you should never validate or test your model on the training data. Your model can be very good at predicting results on your training data, but what you really want is that it can handle never before seen data. That's why we use a seperate portion of the data to validate the model, so  we can see if the model has learned the right thing to also work in the wild and not only in our training environment.
```python
VALIDATION_DATA_SIZE = 10000

x_val = x_train[:VALIDATION_DATA_SIZE]
partial_x_train = x_train[VALIDATION_DATA_SIZE:]
y_val = y_train[:VALIDATION_DATA_SIZE]
partial_y_train = y_train[VALIDATION_DATA_SIZE:]
```

## Defining the model
Now it is finally time to define and compile our model. We will use a very small model with three Dense layers, the first two with 16 units an the last one with only one. The reason for that is that we only need a binary output, so one unit is enough in our output layer. The predictions will be values between 0 and 1. The closer the prediction is to 1, the more likely it is that the given review was positive.
```python
from tensorflow import keras

model = keras.Sequential([
    keras.layers.Dense(16, activation="relu"),
    keras.layers.Dense(16, activation="relu"),
    keras.layers.Dense(1, activation="sigmoid"),
])

model.compile(optimizer="rmsprop", loss="binary_crossentropy", metrics=["accuracy"])
```

Another thing we should take care of here is the activiation function of our output layer. We used "sigmoid" here, which is always a good choice for binary classification problems. The same goes for the optimizer, the mechanism used to improve the model during training, "rmsprop", and the loss function, the mechanism used to calculate how good our model is during training (the lower the loss, the better the model),  "binary_crossentropy, both are usually the best chooice for binary classification tasks.

## Training the model
This step will take a while and it will output the current metrics for each epoch during training. To train the model we call its fit method using our training data and labels as well the number of epochs, the batch size, this is the amount of data that will be processed at a time and also our validation data, which will be used to validate the model on data that wasn't used for training. The fit method will return the training metrics per epoch, which we split up in loss, validation loss, accuracy and validation accurarcy. So we can use that later on to visualize how well our trining performed.
```python
history = model.fit(
    partial_x_train,
    partial_y_train,
    epochs=20,
    batch_size=512,
    validation_data=(x_val, y_val),
)

history_dict = history.history
loss_values = history_dict["loss"]
val_loss_values = history_dict["val_loss"]
acc_values = history_dict["accuracy"]
val_acc_values = history_dict["val_accuracy"]
```

## Visualize training
To see how our model improved during training we plot all the metrics using matplotlib. This is very helpful to improve your model to get better results.
```python
import matplotlib.pyplot as plt

epochs = range(1, len(loss_values) + 1)

plt.plot(epochs, loss_values, "bo", label="Training Loss")
plt.plot(epochs, val_loss_values, "b", label="Validation Loss")
plt.plot(epochs, acc_values, "ro", label="Training Accuracy")
plt.plot(epochs, val_acc_values, "r", label="Validation Accuracy")
plt.legend()
plt.show()
```

## Make predictions
Lastly we can use our model to make predictions on the test data. This is actually very simple, we only have to call the predict method of the model with our test data. The result is a list of values between 0 and 1, one for each review in the test dataset. If the number is close to one it is more likely that this is a positive result and if it is closer to zero, the review is probably negative.
```python
predictions = model.predict(x_test)
print(predictions)
```

The full source code of this can be found [here](https://github.com/salendron/tensorflow_examples/blob/main/001_imdb_binary_classification/main.py).


