---
title: "Multiclass classification with Tensorflow and Keras functional API"
date: 2022-01-13T19:00:25Z
draft: false
tags: ["blog", "howto", "python", "tensorflow", "ml", "maschine learning", "keras"]
---
In [the first part](https://hautzenberger.at/posts/blog/2022-01-10_tensorflow_tutorial_001_binaray_classification/) of this series we developed a simple binary classification model using Keras' Sequential model class, which is the easiest way of using Keras. Since the Squential model is easy to use, but also limited in what we can do with it, we will use Keras' functional API from now on. That way we can build more complex models for use cases that are not so simple. Allthough in this example we will basically use the functional API to build a model that could also be build using the Sequential model to show how it works on with a very simple example and then use this in upcoming parts of this series to implement more complex usecases.

In this example we will implement and train a multiclass classification model to classify reuters newswires using the reuters dataset.

## Prequesites
I assume that you have read the [the first part](https://hautzenberger.at/posts/blog/2022-01-10_tensorflow_tutorial_001_binaray_classification/) of this series and also understand what we did there.

## The training data
First of all we have to load the training data. Which we can do like this:
```python
from tensorflow.keras.datasets import reuters
```

The dataset consists of 11.228 newswires in 46 categories - labels. Like in the last example we will anly load the 10.000 most used word since words that are used not very often aren't helpful for catigorization.
```python
NUM_WORDS = 10000
(train_data, train_labels), (test_data, test_labels) = reuters.load_data(num_words=NUM_WORDS)
```

Tensorflow works best with numbers and therefor we have to find a way how we can represent the review texts in a numeric form. One way of doing this vectorization. That means that we will transform each newswire into a list of numbers which is exactly as long as the amount of words we expect, in this case NUM_WORDS=10000. We first fill it with zeros and then we write a 1 on each index of a word that occured in a certain review.
This will result in a list of lists, one for each newswire, filled with zeros and ones, but only if the word at this index exists. So let's implement a function to do that for us and then vectorize our train and test data.
```python
def vectorize_sequences(sequences, dimension):
    results = np.zeros((len(sequences), dimension))

    for i, sequence in enumerate(sequences):
        for j in sequence:
            results[i, j] = 1.

    return results

x_train = vectorize_sequences(train_data, NUM_WORDS)
x_test = vectorize_sequences(test_data, NUM_WORDS)
```
You noticed that this way we loose all information about how often a word appears, we only set a 1 if it exists at all, and also about where this wird appears in the review. The cool thing is, we do not need that information to predict the category of the newswire. We just need to know which words are in a review and which words aren't.


Now we need to transform our labels into a form which we can use to train the model. One way of doing this is one-hot encoding. This means we generate a list of zeroes and then set a one at the position of the category of the corresponding newswire. So for example if the category of a newswire is 3, then will have an array with a one at the third position, index 2, and the rest will be zeroes. 

Here is a sample implementation of a method to do that yourself:
```python
import numpy as np

NUM_CLASSES = 46

def to_one_hot(labels, dimension): 
    results = np.zeros((len(labels), dimension))

    for i, label in enumerate(labels):
        results[i, label] = 1.

    return results

y_train = to_one_hot(train_labels, NUM_CLASSES) 
y_test = to_one_hot(test_labels, NUM_CLASSES) 
```

But actually you do not have to do this. There is already a helper function in Keras which we can use like this:
```python
from tensorflow.keras.utils import to_categorical

y_train = to_categorical(train_labels) 
y_test = to_categorical(test_labels)
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
Now it is finally time to define and compile our model. We will use a very small model with three layers. This time we use Keras' functional API to do so. The main difference to the Sequential model here is that we define our inputs using the shape of a single input newswire and then define our feature layer, Dense - 16 Units - activation relu, and call it with the input layer to connect it. We do the same for our output layer, but this one has NUM_CLASSES (46) units, because we want to predict the probability for each possible category and we use softmax as activiation function, which is a good choice for multiclass classifications. The model is then defined using the inputs and outputs. This way of defining a model would allow us to build models that have multiple in- and outputs, which is something very helpful in more complex usecases.
```python
from tensorflow import keras
from tensorflow.keras import layers

inputs = keras.Input(shape=(NUM_WORDS, ), name="input")
features = layers.Dense(64, activation="relu")(inputs)
outputs = layers.Dense(NUM_CLASSES, activation="softmax")(features)
model = keras.Model(inputs=inputs, outputs=outputs)

# compile the model
model.compile(optimizer="rmsprop", loss="categorical_crossentropy", metrics=["accuracy"])
```

Another thing we should take care of here is the activiation function of our output layer. We used "softmax" here, which is always a good choice for multiclass classification problems. The same goes for the optimizer, the mechanism used to improve the model during training, "rmsprop", and the loss function, the mechanism used to calculate how good our model is during training (the lower the loss, the better the model),  "categorical_crossentropy, both are usually the best chooice for multiclass classification tasks.

## Training the model
This step will take a while and it will output the current metrics for each epoch during training. To train the model we call its fit method using our training data and labels as well the number of epochs, the batch size, this is the amount of data that will be processed at a time and also our validation data, which will be used to validate the model on data that wasn't used for training. The fit method will return the training metrics per epoch, which we split up in loss, validation loss, accuracy and validation accurarcy. So we can use that later on to visualize how well our trining performed.
```python
history = model.fit(
    partial_x_train,
    partial_y_train,
    epochs=9,
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
Lastly we can use our model to make predictions on the test data. This is actually very simple, we only have to call the predict method of the model with our test data. The result is a list of lists, one for each newswire in testdata, of 46 values between 0 and 1, which represents the probability for each class to fit the corresponding newswire. So if we call np.argmax for the first result it will return the category with the highest probability which hopefully is the correct category of the given newswire.
```python
predictions = model.predict(x_test)
print(
    np.argmax(predictions[0])
)
```

The full source code of this can be found [here](https://github.com/salendron/tensorflow_examples/blob/main/002_multiclass_classification/main.py).


