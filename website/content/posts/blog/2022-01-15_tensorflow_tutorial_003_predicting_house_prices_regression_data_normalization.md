---
title: "Using regression to predict house prices using Tensorflow and Keras"
date: 2022-01-15T18:00:25Z
draft: false
tags: ["blog", "howto", "python", "tensorflow", "ml", "maschine learning", "keras"]
---
In this example we will use Boston housing price dataset to predict house prices based on several features such as crime rate, local tax property rate and so on. The biggest differenc to the previous example here is that we do not predict fixed classes. This time we predict a continous value. 

## Prequesites
This is the third part of my Tensorflow and Keras Sample series. To better understand what is going on here I highly recommend to read [part 1](https://hautzenberger.at/posts/blog/2022-01-10_tensorflow_tutorial_001_binaray_classification/) and [part 2](https://hautzenberger.at/posts/blog/2022-01-13_tensorflow_tutorial_002_multiclass_classification_functional_api/) first and then return here to continue.

## The training data
First of all we have to load the training data. Which we can do like this:
```python
from tensorflow.keras.datasets import boston_housing
```

The dataset consists of 506 "houses"  defined by their 13 - numerical - properties and a price. So the 13 features per house are our input and the prices are what we want to predict in the end. This example could be applied to a lot of other use cases. For example to predict Ice cream sold based on current temperature, number of skiers to expect on the slopes based on yesterdays snowfall and so.
```python
NUM_WORDS = 10000
(train_data, train_labels), (test_data, test_labels) = reuters.load_data(num_words=NUM_WORDS)
```

This time we do not need to convert our data to numbers, because each house is defined by 13 values, which are already numbers, but they have very different ranges. Some values are between 0 and 1 and some between 0 and 100. It is far easier for Tensorflow to train on data that has  similar ranges. So what we need to do is normalize the data. Thanks to numpy this is very easy. We just nee to substract the mean of each property from each value and the devide them by their standard deviation. This will result in all features to center arround 0. 
```python
mean = train_data.mean(axis=0)
train_data -= mean
std = train_data.std(axis=0)
train_data /= std
test_data -= mean
test_data /= std
```

## Defining the model
Our model consist of an input layer with the shape of (13,), 13 values dor each house, a dense feature layer with 64 units and a dense output layer with one unit, which will output the predicted price of the house in thousand dollars. The prices may seem very low, but remember that these from the 70s. So if the model outputs something like 7,834, this means that the predicted price if 7.834$.
```python
from tensorflow import keras

inputs = keras.layers.Input((13,))
features = keras.layers.Dense(64, activation="relu")(inputs)
outputs = keras.layers.Dense(1)(features)
model = keras.Model(inputs=inputs, outputs=outputs)

model.compile(optimizer="rmsprop", loss="mse", metrics=["mae"])
```

We use "mae" as our metric this time, which stands for "mean absolut error". It computes the absolute error between the expected value and the prediction. As our loss function we use "mse", which stands for "mean squared error", which computesd the "mean suared error" between the expected value and the prediction during training. Both of them are a good choice for regression tasks since the work well to judge how close our model get'S to the expected value. As optimizer we use "rmsprop" to optimize our model based on the current loss.

## Training the model
This step is pretty straight forward. We just pass our trainin data and training targets to the model, specify for how many epochs we want to train and our batch size. In a future posts I will descirbe how to come up with a good numbers for epochs and batch size. For now just take them as they are, or try to experiment with them yourself.
```python
model.fit(train_data, train_targets, epochs=150, batch_size=64)
test_mse_score, test_mae_score = model.evaluate(test_data, test_targets)
print(test_mae_score)
```

## Make predictions
Now that our model is trained, we can use it to predict the prices of houses in the test part of our data.
```python
predictions = model.predict(test_data)
predicted_value = predictions[0][0]
real_value = test_targets[0]
print(f"Predicted Price: {predicted_value} - Real Price: {real_value}")
```

In my test this resulted in a predicted price of 7.69622802734375, so about 7.696$ and the real price was 7.200$, whic is already pretty close. So our model did actually pretty well, allthough we had very little data to train on.

The full source code of this can be found [here](https://github.com/salendron/tensorflow_examples/blob/main/003_regession_boston_housing_prices/main.py).


