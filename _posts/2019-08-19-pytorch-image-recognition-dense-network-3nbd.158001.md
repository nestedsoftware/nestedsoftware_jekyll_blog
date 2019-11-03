---
title: PyTorch Image Recognition with Dense Network
published: true
cover_image: /assets/images/2019-08-19-pytorch-image-recognition-dense-network-3nbd.158001/vimg1nkfe1n49p2kfdqf.jpg
description: PyTorch implementation of a simple fully connected network for recognizing MNIST digits
series: PyTorch
canonical_url: https://nestedsoftware.com/2019/08/19/pytorch-image-recognition-dense-network-3nbd.158001.html
tags: python, pytorch, neuralnetworks, mnist
---

In the last article, we verified that a manual backpropagation calculation for a tiny network with just _2_ neurons matched the results from PyTorch. We'll continue in a similar spirit in this article: This time we'll implement a fully connected, or dense, network for recognizing handwritten digits (_0_ to _9_) from the MNIST database, and compare it with the results described in [chapter 1](http://neuralnetworksanddeeplearning.com/chap1.html#exercise_358114) of Michael Nielsen's book, [Neural Networks and Deep Learning](http://neuralnetworksanddeeplearning.com/).

The [code](https://github.com/nestedsoftware/pytorch) for this project is available on github.

## Network Structure

The network Michael Nielsen describes in chapter 1 takes _28 x 28_ greyscale pixel MNIST images as input and runs them through a fully connected hidden layer of _100_ sigmoid-activated neurons. This hidden layer then feeds into a fully connected output layer of _10_ sigmoid-activated neurons. Each neuron in the output layer represents a digit, so the output neuron with the highest activation represents the network's prediction. For more details, you can also check out my article, [Neural Networks Primer]({% link _posts/2019-05-05-neural-networks-primer-374i.105712.md %})

The code that describes the simple network we'll be using for this article is shown below ([pytorch_mnist.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist.py)):

```python
INPUT_SIZE = 28 * 28
OUTPUT_SIZE = 10
NUM_EPOCHS = 30
LEARNING_RATE = 3.0


class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.hidden_layer = nn.Linear(INPUT_SIZE, 100)
        self.output_layer = nn.Linear(100, OUTPUT_SIZE)

    def forward(self, x):
        x = torch.sigmoid(self.hidden_layer(x))
        x = torch.sigmoid(self.output_layer(x))
        return x
```

## Running the Network

The high-level code below loads the data, trains the network using the training dataset, then tests the network using the testing dataset ([pytorch_mnist.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist.py)):

```python
def run_network(net):
    mse_loss_function = nn.MSELoss()
    sgd = torch.optim.SGD(net.parameters(), lr=LEARNING_RATE)

    train_loader = get_train_loader()
    train_network(train_loader, net, NUM_EPOCHS, sgd,
                  create_input_reshaper(),
                  create_loss_function(mse_loss_function))

    print("")

    test_loader = get_test_loader()
    test_network(test_loader, net, create_input_reshaper())
```

We are using stochastic gradient descent to update the weights and biases, and we're using a simple mean squared error function to compute the cost, or loss. The terms _quadratic cost function_ and _mean squared error loss function_ refer to the same thing.


## Data Loading

PyTorch has convenient built-in loaders for the MNIST datasets (among others), so we don't have to write code from scratch to download and prepare the data. Let's take a look at how this works ([common.py](https://github.com/nestedsoftware/pytorch/blob/master/common.py)):

```python
import torch
import torchvision.transforms as transforms
import torchvision.datasets as datasets

BATCH_SIZE = 10

# transforms each PIL.Image to a tensor that can be used as input in pytorch
transformations = transforms.Compose([transforms.ToTensor()])


def get_dataset(root="./data", train=True, transform=transformations,
                download=True):
    return datasets.MNIST(root=root, train=train, transform=transform,
                          download=download)


def get_loader(dataset, batch_size=BATCH_SIZE, shuffle=True):
    return torch.utils.data.DataLoader(dataset=dataset, batch_size=batch_size,
                                       shuffle=shuffle)


def get_train_loader():
    train_dataset = get_dataset()
    train_loader = get_loader(train_dataset)
    return train_loader


def get_test_loader():
    test_dataset = get_dataset(train=False)
    test_loader = get_loader(test_dataset, shuffle=False)
    return test_loader
```

The `torchvision.datasets.MNIST` object represents the data from the MNIST database. By default, each image is in [PIL](https://en.wikipedia.org/wiki/Python_Imaging_Library) format. PyTorch allows us to supply transformations when generating datasets. Here we just transform the images in the dataset from PIL format into PyTorch tensors, but there are [more powerful tools](https://pytorch.org/tutorials/beginner/data_loading_tutorial.html#transforms) for manipulating the incoming data as well. We use the following flags:

* The `download` flag allows us to download the data from the Internet if necessary, then to store it locally (in `"./data"` for this example). Once it has been stored, the dataset is loaded locally the next time around.

* The `train` flag determines whether the training dataset (_60,000_ images) or the testing dataset (_10,000_ images) is loaded.

The object created by `torch.utils.data.DataLoader` lets us work with a dataset once it's been loaded. The [options](https://pytorch.org/docs/stable/data.html) we use are `batch_size` and `shuffle`:

* `batch_size` represents the number of images to run through a given network before updating the weights and biases. To improve performance, neural networks usually employ some variation of stochastic gradient descent for backpropagation: We run multiple images through the network at a time. The resulting gradients are averaged together before updating the weights and biases.  Each time we get the next item from the loader's iterator, that item will contain a number of images that corresponds to the value that was set for `batch_size`. In the code above, we use _10_ images per batch to match the configuration in Michael Nielsen's book.

* `shuffle` tells us whether to randomize the order of items in the dataset before iterating over it. With neural networks, we often train the network over the entire training dataset more than once. The term _epoch_ is used to describe each time we go through all of the data in the training dataset. To improve the ability of the network to generalize to new data that it hasn't seen before, the `shuffle` option is used to re-order the data for each such training epoch.

## Structure of MNIST Data

Let's use the Python REPL to explore the structure of the data:

```python
>>> import common as c
>>> train_dataset = c.get_dataset()
>>> len(dataset)
60000
>>> test_dataset = c.get_dataset(train=False)
>>> len(train_dataset)
10000
```

Above, we can see that our training data set contains _60,000_ images, and our test dataset contains _10,000_ images. What does the data prepared by the data loader look like?

```python
>>> import common as c
>>> data_loader = c.get_test_loader()
>>> images, expected_results = next(iter(data_loader))
>>> len(images)
10
>>> len(expected_results)
10
>>> expected_results
tensor([7, 2, 1, 0, 4, 1, 4, 9, 5, 9])
```

For each batch, our loader returns a tuple with two items in it: The first item in the tuple is an array of the images in that batch. The second item is an array of the actual values that the images are meant to represent. Here, since we've set the `batch_size` to 10, we get a tuple of _10_ images and _10_ expected results from the test data loader. The above code displays the expected values for the test images loaded in the first batch. Now let's take a closer look at the images themselves:

```python
>>> images.size()
torch.Size([10, 1, 28, 28])
```

We can think of this as follows: There are _10_ images, and each image is a 3-dimensional array, of size `(1, 28, 28)`. The _1_ means each image has a single channel. The MNIST data is in greyscale, and each pixel is a value between _0.0_ (black) and _1.0_ (white). For colored images, there would be _3_ channels (usually red, green, and blue), and in each channel, there would be a 2-dimensional array of values representing the intensity of that color within the image.

This data from the loader is already set up correctly to be used as input for a convolutional neural network, which we'll look at in the next article. However, in this case we have a fully connected hidden layer instead. Therefore, as discussed in [Neural Networks Primer]({% link _posts/2019-05-05-neural-networks-primer-374i.105712.md %}), we'll need to flatten each image into a one-dimensional array. Here's a neat way to do that in PyTorch:

```python
>>> images_reformatted = images.reshape(-1, 28*28)
>>> images_reformatted.size()
torch.Size([10, 784])
```

When we supply _-1_ as an argument to `images.reshape`, it's treated as a placeholder. PyTorch knows that the total number of values in the array is _10 * 1 * 28 * 28 = 7, 840_. Since we specify that we want the second dimension of the array to be of size _28 * 28_, or _784_, PyTorch can work out that the _-1_ has to correspond to _10_. This lets us turn each _1 x 28 x 28_ image in the batch into a _784_ pixel array (removing the unnecessary color channel in the process). As long as we know the input size that we want, this will work regardless of the number of images in each batch.

## Network Output Before and After Training

We can now use these reformatted images as input for our fully connected network. Let's run our first batch of images through our network in the Python REPL:

```python
>>> import torch
>>> import common as c
>>> import pytorch_mnist as mnist
>>>
>>> data_loader = c.get_test_loader()
>>> images, expected_results = next(iter(data_loader)) # batch from test data
>>> expected_results[0]
tensor(7) # the expected result is a 7 for the first test image
>>>
>>> images_reformatted = images.reshape(-1, 28*28)
>>> net = mnist.Net()
>>> outputs = net(images_reformatted) # before training, outputs for test batch
>>> outputs[0] # outputs for first test image are scattered randomly
tensor([0.4313, 0.4844, 0.5163, 0.5135, 0.5347, 0.5641, 0.4823, 0.4459, 0.5161,
        0.4919], grad_fn=<SelectBackward>)
```

We get our first batch of images from the test dataset, reformat them, and send them all at once as input to our network. The network dutifully returns _10_ outputs. Each output is an array of _10_ floating point values. Above, we show the network's output for the first image. Since the network hasn't been trained yet, the output values are all random. After the network has been trained, there should be one value that's very close to _1.0_, corresponding to the predicted digit, and the rest should be very close to _0.0_.

Let's continue our REPL session. Below, we will train the network and then check the output for the first image again:

```python
>>> mnist.run_network(net) # now let's train the network
Epoch [1/30], Step [100/6000], Loss: 0.0797
# ...omitting intermediate steps
Epoch [30/30], Step [6000/6000], Loss: 0.0001

Test data results: 0.9785
>>> outputs = net(images_reformatted) # after training, outputs for test batch
>>> outputs[0]
tensor([1.3546e-04, 4.1909e-06, 5.8085e-06, 9.5294e-05, 4.5417e-07, 5.6720e-04,
        1.3523e-09, 9.9983e-01, 1.4206e-05, 1.7880e-05],
       grad_fn=<SelectBackward>)
>>> output_value, output_index = torch.max(outputs[0], 0)
>>> output_value
tensor(0.9998, grad_fn=<MaxBackward0>) # the highest output value is almost 1
>>> output_index # the predicted digit, i.e. the index of the highest value is 7
tensor(7)
>>> c.transforms.ToPILImage()(images[0]).show()
```

Initially all the output values for the first image were quite random, and the one corresponding to the digit _5_ had the highest value (_0.5641_). After training the network, all of the output values are now close to zero, except for the one that corresponds to a seven, which is _0.9998_, or almost _1_. The corresponding target value in the test data is in fact _7_, so the network now guesses correctly! Below is a magnified version of the image displayed by the last line of code above:

![mnist test image](/assets/images/2019-08-19-pytorch-image-recognition-dense-network-3nbd.158001/tu6jr7pwervlz93zm32l.png)

We can also see that, after _30_ epochs of training, our network performed with an accuracy of _97.85%_ against the test data. That's a bit higher than the _96.59%_ published by Michael Nielsen, an improvement of _126_ images (out of the _10,000_ images in the test dataset). Overall, these results seem reasonably consistent with the findings in the book.

## Calculating The Loss Function

Below is the code that trains the network ([common.py](https://github.com/nestedsoftware/pytorch/blob/master/common.py)):

```python
def train_network(data_loader, model, num_epochs, optimizer, reshape_input,
                  calc_loss):
    num_batches = len(data_loader)
    for epoch in range(num_epochs):
        for batch in enumerate(data_loader):
            i, (images, expected_outputs) = batch

            images = reshape_input(images)
            outputs = model(images)
            loss = calc_loss(outputs, expected_outputs)

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

            if (i+1) % 100 == 0 or (i+1) == num_batches:
                p = [epoch+1, num_epochs, i+1, num_batches, loss.item()]
                print('Epoch [{}/{}], Step [{}/{}], Loss: {:.4f}'.format(*p))
```

Note that we pass in `calc_loss` as a callback to `train_network`. This function calculates the cost, or loss, for the expected values relative the what the network actually outputs. For this network, we're using the mean squared error loss function. For a given image, our network ouputs an array of _10_ values, where each value represents how confident it is that the index for that value corresponds to the digit represented by the input. The expected output that we get from the data loader is just the actual number, from _0_ to _9_. Therefore, for backpropagation, we need to translate the expected output into an array of values that matches the network's output. The code that does this conversion is shown below ([pytorch_mnist.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist.py)):

```python
def expand_expected_output(tensor_of_expected_outputs, output_size):
    return torch.tensor([expand_single_output(expected_output.item(),
                                              output_size)
                         for expected_output in tensor_of_expected_outputs])


# Expand expected output for comparison with the outputs from the network,
# e.g. convert 3 to [0., 0., 0., 1., 0., 0., 0., 0., 0., 0.]
def expand_single_output(expected_output, output_size):
    x = [0.0 for _ in range(output_size)]
    x[expected_output] = 1.0
    return x
```

Let's say, as we saw earlier, that the expected outputs for a given batch are stored as `tensor([7, 2, 1, 0, 4, 1, 4, 9, 5, 9])`. `expand_expected_output` will take this tensor as input for `tensor_of_expected_outputs`, and _10_ for `output_size`. For each expected value, it will produce an array where nine of the values are set to _0.0_, and the single value at the index corresponding to the correct output is set to _1.0_:

```python
>>> import torch
>>> import pytorch_mnist as mnist
>>> expected_results = torch.tensor([7, 2, 1, 0, 4, 1, 4, 9, 5, 9])
>>> mnist.transform_expected_output(expected_results, 10)
tensor([[0., 0., 0., 0., 0., 0., 0., 1., 0., 0.],
        [0., 0., 1., 0., 0., 0., 0., 0., 0., 0.],
        [0., 1., 0., 0., 0., 0., 0., 0., 0., 0.],
        [1., 0., 0., 0., 0., 0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 1., 0., 0., 0., 0., 0.],
        [0., 1., 0., 0., 0., 0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 1., 0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0., 0., 0., 0., 0., 1.],
        [0., 0., 0., 0., 0., 1., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0., 0., 0., 0., 0., 1.]])
```

After the weights and biases are updated, This will push the outputs that are assigned _0.0_ down, and the output assigned to _1.0_ up, for the same image.


## Testing the Network

After the network has been trained, the `test_network` function below checks how many predictions it gets right ([common.py](https://github.com/nestedsoftware/pytorch/blob/master/common.py)):

```python
def test_network(data_loader, model, reshape):
    with torch.no_grad():
        correct = 0
        total = 0
        for batch in data_loader:
            images, expected_outputs = batch

            images = reshape(images)
            outputs = model(images)

            # get the predicted value from each output in the batch
            predicted_outputs = torch.argmax(outputs, dim=1)

            total += expected_outputs.size(0)
            correct += (predicted_outputs == expected_outputs).sum()

        print(f"Test data results: {float(correct)/total}")
```

Some notes on the code in this function:

* `torch.no_grad()` reduces memory usage when we just want to get the outputs from the network, and we're not worried about updating the gradients

* `torch.argmax(outputs, dim=1)` gives us the index of the maximum value in each row of outputs. Setting `dim=0` would give us the index of the maximum value in each column.

*  If `expected_outputs` is a one-dimensional tensor with _10_ items in it, its size will be `torch.Size([10])`. `expected_outputs.size(0)` retrieves the first (and, in this case, only) item from the `Size` object, i.e. the value _10_. This gives us the total number of expected outputs for the batch, from which we can then calculate the fraction of actual outputs that match.

* `predicted_outputs == expected_outputs` produces a tensor with a _1_ where the values in the `predicted_outputs` and  `expected_outputs` tensors match, and a _0_ where they don't. The `sum()` therefore gives us the number of correct predictions for a batch of images.

## Demo

That completes this overview. Even though the network we've implemented is very simple, we've already learned quite a lot of important fundamentals about PyTorch. After downloading the code from github (see below), you can run the demo that goes along with this article as follows:

```cmd
C:\Dev\python\pytorch>python pytorch_mnist.py
Epoch [1/30], Step [100/6000], Loss: 0.0885
...
Epoch [30/30], Step [6000/6000], Loss: 0.0025

Test data results: 0.9796
```
## Code

The code for this article is available in full on github:

* [https://github.com/nestedsoftware/pytorch](https://github.com/nestedsoftware/pytorch)


## References:

* [Chapter 1](http://neuralnetworksanddeeplearning.com/chap1.html) of Neural Networks and Deep Learning, by Michael Nielsen
* [PyTorch](https://github.com/nestedsoftware/pytorch)
* [PIL - Python Imaging Library](https://en.wikipedia.org/wiki/Python_Imaging_Library)
* [DataLoader options](https://pytorch.org/docs/stable/data.html)
* [PyTorch Data Loading and Processing Tutorial - Transforms](https://pytorch.org/tutorials/beginner/data_loading_tutorial.html#transforms)

## Related

* [Neural Networks Primer]({% link _posts/2019-05-05-neural-networks-primer-374i.105712.md %})
