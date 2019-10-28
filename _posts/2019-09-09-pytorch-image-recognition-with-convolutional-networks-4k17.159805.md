---
title: PyTorch Image Recognition with Convolutional Networks
published: true
cover_image: /assets/images/2019-09-09-pytorch-image-recognition-with-convolutional-networks-4k17.159805/hzc4hdwc234t7p728i5c.jpg
description: Convolutional network variations for recognizing MNIST digits
series: PyTorch
canonical_url: https://nestedsoftware.github.io/2019/09/09/pytorch-image-recognition-with-convolutional-networks-4k17.159805.html
tags: python, pytorch, cnn, mnist
---

In the last article, we implemented a simple dense network to recognize MNIST images with PyTorch. In this article, we'll stay with the MNIST recognition task, but this time we'll use convolutional networks, as described in [chapter 6](http://neuralnetworksanddeeplearning.com/chap6.html) of Michael Nielsen's book, [Neural Networks and Deep Learning](http://neuralnetworksanddeeplearning.com). For some additional background about convolutional networks, you can also check out my article [Convolutional Neural Networks: An Intuitive Primer]({% link _posts/2019-05-28-convolutional-neural-networks-an-intuitive-primer-k1k.114570.md %}).

We'll compare our PyTorch implementations to Michael's results using [code](https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/conv.py) written with the (now defunct) [Theano](https://github.com/Theano/Theano) library. You can also take a look at the underlying [framework code](https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/network3.py) he developed on top of Theano. PyTorch seems to be more of a "batteries included" solution compared to Theano, so it makes implementing these networks much simpler. The dense network from the previous article had an accuracy close to _98%_. Our ultimate goal for our convolutional network will be to match the _99.6%_ accuracy that Michael achieves.

The [code](https://github.com/nestedsoftware/pytorch) for this project is available on github, mainly in [pytorch_mnist_convnet.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist_convnet.py).

## Simple Convolutional Network

The first convolutional network design that Michael presents is [`basic_conv`](https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/conv.py). Our PyTorch implementation is shown below ([pytorch_mnist_convnet.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist_convnet.py)):

```python
class ConvNetSimple(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(in_channels=1, out_channels=20, kernel_size=5)
        self.fc1 = nn.Linear(12*12*20, 100)
        self.out = nn.Linear(100, OUTPUT_SIZE)

    def forward(self, x):
        x = self.conv1(x)
        x = torch.sigmoid(x)
        x = torch.max_pool2d(x, kernel_size=2, stride=2)

        x = x.view(-1, 12*12*20)
        x = self.fc1(x)
        x = torch.sigmoid(x)

        x = self.out(x)
        return x
```

In this network, we have 3 layers (not counting the input layer). The image data is sent to a convolutional layer with a _5 × 5_ kernel, _1_ input channel, and _20_ output channels. The output from this convolutional layer is fed into a dense (aka fully connected) layer of _100_ neurons. This dense layer, in turn, feeds into the output layer, which is another dense layer consisting of _10_ neurons, each corresponding to one of our possible digits from _0_ to _9_.

The `forward` method is called when we run input through the network. We use sigmoid activation functions for each of our layers, except for the output layer (we'll look at this in more detail in the next few sections). We also compress the output from our convolutional layer in half by applying _2 × 2_ max pooling to it, with a stride length of _2_. The diagram below shows the structure of this network:

![convolutional network](/assets/images/2019-09-09-pytorch-image-recognition-with-convolutional-networks-4k17.159805/p4q7xbnn5o13noe9hqnk.png)

In the previous article, we saw that the data returned by the loader has dimensions `torch.Size([10, 1, 28, 28])`. This means there are _10_ images per batch, and each image is represented as a _1 × 28 × 28_ grid. The _1_ means there is a single input channel (the data is in greyscale). The diagram below shows in more detail how the input is processed through the convolutional layer:

![convolutional layer with max pooling](/assets/images/2019-09-09-pytorch-image-recognition-with-convolutional-networks-4k17.159805/ctzw0mndjoonee3ybzmh.png)

In SciPy, [`convolve2d`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.convolve2d.html) does just what is says: It convolves two 2-d matrices together. The behaviour of `torch.nn.Conv2d` is more complicated. The line of code that creates the convolutional layer, `self.conv1 = nn.Conv2d(in_channels=1, out_channels=20, kernel_size=5)`, has a number of parts to it:

* `kernel_size` tells us the 2-d structure of the filter to apply to the input. We can supply this as tuple if we want it to be a rectangle, but if we specify it as a scalar, as we do here, then that value is used for both the height and width, a _5 × 5_ square in this case.
* `in_channels` extends the kernel into the 3rd dimension, depth-wise. These three parameters, the height and width of the kernel, and the depth as specified by the number of input channels, define a 3-d matrix. We can convolve the 3-d input with this 3-d filter. The result is a _24 × 24_ 2-d matrix. This 2-d matrix is a feature map. Each neuron in this feature map identifies the same _5 × 5_ feature somewhere in the receptive field of the input.
* `out_channels` tells us how many filters to use - in other words, how many feature maps we want for the convolutional layer. The 2-d outputs from the convolution of the input with each filter are stacked on top of one another.

Even though I think of this as a 3-d operation (especially when there is more than one input channel), I guess it's called `Conv2d` in PyTorch to indicate that each channel has a 2-dimensional shape (`Conv3d` is used when each channel has _3_ dimensions). I go into more detail about forward and back propagation through convolutional layers in [Convolutional Neural Networks: An Intuitive Primer]({% link _posts/2019-05-28-convolutional-neural-networks-an-intuitive-primer-k1k.114570.md %}).

Conceptually, each filter produces a feature map, which represents a feature that we're looking for in the receptive field of the input data. In this case, that means the network learns _20_ distinct _5 × 5_ features. During forward propagation, `max_pool2d` compresses each feature. It's applied to each channel, turning each _24 × 24_ feature map into a _12 × 12_ matrix for each channel. The result is a 3-d matrix with the same depth (_20_ channels in this case).

Note, as shown below, that `Conv2d` technically performs a cross-correlation rather than a true convolution operation (`Conv2d` calls `conv2d` internally):

```python
>>> import torch
>>> from torch import nn
>>> from scipy import signal
>>> values = torch.tensor([[[[1,2,3],[4,5,6],[7,8,9]]]])
>>> f = torch.tensor([[[[10,20],[30,40]]]])
>>> nn.functional.conv2d(values, f)
tensor([[[[370, 470],
          [670, 770]]]])
>>> signal.correlate2d(values[0,0], f[0,0], mode="valid")
array([[370, 470],
       [670, 770]], dtype=int64)
```

## Softmax

We want the output to indicate which digit the image corresponds to. In other words, we want the output for the correct prediction to be as close to _1_ as possible, and for the rest of the outputs to be as close to _0_ as possible.

First, we will normalize our outputs so that they add up to _1_, thus turning our ouput into a probability distribution. The simple way to normalize our outputs would be just to divide each output by the sum of all of the outputs (_N_ is the number of outputs):

![normalize output](/assets/images/2019-09-09-pytorch-image-recognition-with-convolutional-networks-4k17.159805/onbx2gx8j8qcs2jqejka.png)

We will use a function called [_softmax_](https://en.wikipedia.org/wiki/Softmax_function) instead. With softmax, we adjust the above formula by applying the exponential function to each output:

![softmax output](/assets/images/2019-09-09-pytorch-image-recognition-with-convolutional-networks-4k17.159805/0vzj1rupkekbepd3ssw1.png)

Why should we do this? I don't think Michael compares softmax with the simple linear normalization shown earlier. One benefit is that, with softmax, the highest output value will get an exponentially greater proportion of the total. This encourages our network to more sharply favour the highest output over all of the others. This approach also has the advantage that any negative outputs will be automatically converted to positive values - since the exponential function returns a positive value for any input (it approaches _0_ as _x_ goes to negative infinity).

You may also want to see what Michael has to say about [softmax](http://neuralnetworksanddeeplearning.com/chap3.html#softmax) in [Neural Networks and Deep Learning](http://neuralnetworksanddeeplearning.com), as he goes into some interesting additional discussion of its properties.

## Negative Log Likelihood Loss

Once we have the output transformed with softmax, we need to compute the loss. For this, we'll use the _negative log likelihood_ loss function. For the target value, where we want the probability to be close to _1_, the loss is _f(x) = -ln(x)_, where _x_ is the network's output for the desired prediction. Why should we use the negative log instead of our old friend, the quadratic cost function? I found it helpful to compare negative log against the quadratic cost, _f(x) = (x - 1)<sup>2</sup>_:

![loss function comparison](/assets/images/2019-09-09-pytorch-image-recognition-with-convolutional-networks-4k17.159805/nvstofwjzk07bkkv3iq3.png)

We can see that the cost goes down to _0_ for both functions as the output approaches _1_, which is what we want. The advantage of the log likelihood over quadratic cost is that the cost for log likelihood rises much faster as the output moves away from _1_ and toward _0_. That means the gradients we compute get much higher the farther away they are from the target. This should increase the speed with which our network learns.

## Cross Entropy Loss

There are several ways that we could compute the negative log likelihood loss. We could run our output through softmax ourselves, then compute the loss with a custom loss function that applies the negative log to the output. This is what Michael Nielsen's Theano code does. However, the simplest way to do it in PyTorch is just to use [`CrossEntropyLoss`](https://pytorch.org/docs/stable/nn.html#crossentropyloss).  `CrossEntropyLoss` does everything for us, which includes applying softmax to the output - that's why we don't do it ourselves, as mentioned earlier.

`CrossEntropyLoss()` produces a loss function that takes two parameters, the outputs from the network, and the corresponding index of the correct prediction for each image in the batch. In our case, we can use the target digit as this index: If the image corresponds to the number _3_, then the output from the network that we want to increase is `output[3]`.

> During backpropagation, using `CrossEntropyLoss` only adjusts the weights and biases corresponding to the correct prediction. The gradients for the wrong predictions are just set to zero. Because softmax is applied to the output, any increase to the correct output after backpropagation means that the other outputs will be adjusted downward to compensate (to insure that the total still adds up to _1_).

To demonstrate why we use `CrossEntropyLoss`, let's say we've got an output of `[0.2, 0.4, 0.9]` for some network. We want the 3rd output, currently _0.9_, to be the correct one, i.e. we want to increase that output toward _1_. The REPL session below shows several loss calculations that produce the same result: We apply softmax followed by negative log; we take the negative value of `log_softmax`; we compute `NLLLoss` after `log_softmax`; we use `CrossEntropyLoss` with the raw output:

```python
>>> import torch
>>> from torch import nn
>>> output = torch.tensor([[0.2, 0.4, 0.9]]) # raw output doesn't add up to 1
>>> output_after_softmax = torch.softmax(output, dim=1)
>>> output_after_softmax
tensor([[0.2361, 0.2884, 0.4755]]) # output adds up to 1 after softmax
>>> negative_log_likelihood = -torch.log(output_after_softmax[0,2])
>>> negative_log_likelihood
tensor(0.7434) # loss for target
>>> output_after_log_softmax = torch.log_softmax(output, dim=1)
>>> output_after_log_softmax_3rd_item = output_after_log_softmax[0,2]
>>> output_after_log_softmax_3rd_item * -1
tensor(0.7434) # loss for target is same as above
>>> negative_log_likelihood_loss = nn.NLLLoss()
>>> negative_log_likelihood_loss(output_after_log_softmax, torch.tensor([2]))
tensor(0.7434) # loss for target is same as above
>>> cross_entropy_loss = nn.CrossEntropyLoss()
>>> cross_entropy_loss(output, torch.tensor([2]))
tensor(0.7434) # loss for target is same as above
```

We can see that all of the above calculations produce the same loss value for our desired output. `CrossEntropyLoss` uses `torch.log_softmax` behind the scenes. The advantage of using `log_softmax` is that it is more numerically stable (i.e. deals with floating point precision better) than calculating `softmax` first, then applying `log` to the result as a separate step.

## Results for Simple Convolutional Network

The code below performs a training run for our network ([pytorch_mnist_convnet.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist_convnet.py)):

```python
def train_and_test_network(net, num_epochs=60, lr=0.1, wd=0,
                           loss_function=nn.CrossEntropyLoss(),
                           train_loader=get_train_loader(),
                           test_loader=get_test_loader()):
    sgd = torch.optim.SGD(net.parameters(), lr=lr, weight_decay=wd)

    train_network(net, train_loader, num_epochs, loss_function, sgd)

    print("")

    test_network(net, test_loader)
```

We can see that we that we use `CrossEntropyLoss` by default to compute the loss. Let's train our simple network on the MNIST dataset:

```python
>>> from pytorch_mnist_convnet import train_and_test_network, ConvNetSimple
>>> net = ConvNetSimple()
>>> train_and_test_network(net)
Test data results: 0.9897
```

After 60 epochs, with a learning rate of _0.1_, we get an accuracy of _98.97%_. Michael Nielsen reports _98.78%_, so our network seems to be in the right ballpark.

## Add a Second Convolutional layer

The next convolutional network Michael presents, [`dbl_conv`](https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/conv.py), adds a second convolutional layer. The code below shows the structure of this network in PyTorch ([pytorch_mnist_convnet.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist_convnet.py)):

```python
class ConvNetTwoConvLayers(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(in_channels=1, out_channels=20, kernel_size=5)
        self.conv2 = nn.Conv2d(in_channels=20, out_channels=40, kernel_size=5)
        self.fc1 = nn.Linear(4*4*40, 100)
        self.out = nn.Linear(100, OUTPUT_SIZE)

    def forward(self, x):
        x = self.conv1(x)
        x = torch.sigmoid(x)
        x = torch.max_pool2d(x, kernel_size=2, stride=2)

        x = self.conv2(x)
        x = torch.sigmoid(x)
        x = torch.max_pool2d(x, kernel_size=2, stride=2)

        x = x.view(-1, 4*4*40)
        x = self.fc1(x)
        x = torch.sigmoid(x)

        x = self.out(x)
        return x
```

The diagram below shows how the output from the first convolutional layer is fed into the second one.

![second convolutional layer](/assets/images/2019-09-09-pytorch-image-recognition-with-convolutional-networks-4k17.159805/86n04id9njyuys2wvwc4.png)

The previous convolutional layer learns _20_ distinct features from the input image. We now take these _20_ feature maps and send them as input to the second convolutional layer. For each filter in the second convolutional layer, this does two things:

* For each incoming channel, we compress together adjacent features across the receptive field.
* We then combine together these compressed features across channels. The result is a 2-dimensional feature map.

Each feature map corresponds to a different combination of features from the previous layer, based on the weights for its specific filter. After max pooling, we end up with a _4 × 4_ grid of feature neurons. Each neuron here represents a complicated aggregation of _16 × 16_ pixels from the original image (each one is offset by _4_ pixels). Since we've got _40_ filters (the number of outgoing channels), we end up with _40_ such feature maps as the output from the second convolutional layer.

## Results for Two Convolutional Layers

The only difference between this network and the previous one is the additional convolutional layer. Let's train this network on the MNIST dataset:

```python
>>> from pytorch_mnist_convnet import ConvNetTwoConvLayers, train_and_test_network
>>> net = ConvNetTwoConvLayers()
>>> train_and_test_network(net)
Test data results: 0.9905
```

After 60 epochs, with a learning rate of _0.1_, we get an accuracy of _99.05%_. Michael Nielsen reports _99.06%_, so this time the results are really close.

## Replace Sigmoid with ReLU

The next network, [`dbl_conv_relu`](https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/conv.py),  replaces the sigmoid activations with rectified linear units, or [_ReLU_](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)). Our PyTorch version is shown below ([pytorch_mnist_convnet.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist_convnet.py)):

```python
class ConvNetTwoConvLayersReLU(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(in_channels=1, out_channels=20, kernel_size=5)
        self.conv2 = nn.Conv2d(in_channels=20, out_channels=40, kernel_size=5)
        self.fc1 = nn.Linear(4*4*40, 100)
        self.out = nn.Linear(100, OUTPUT_SIZE)

    def forward(self, x):
        x = self.conv1(x)
        x = torch.relu(x)
        x = torch.max_pool2d(x, kernel_size=2, stride=2)

        x = self.conv2(x)
        x = torch.relu(x)
        x = torch.max_pool2d(x, kernel_size=2, stride=2)

        x = x.view(-1, 4*4*40)
        x = self.fc1(x)
        x = torch.relu(x)

        x = self.out(x)
        return x
```

ReLU is discussed near the end of [chapter 3](http://neuralnetworksanddeeplearning.com/chap3.html) of [Neural Networks and Deep Learning](http://neuralnetworksanddeeplearning.com). The main advantage of ReLU seems to be that, unlike sigmoid, it doesn't cut off the activation and therefore squash the gradient to a value that's near _0_. This can help us to increase the depth, i.e the number of layers, in our networks. Otherwise, multiplying many small gradients together during backpropagation via the chain rule can lead to the [vanishing gradient problem](https://en.wikipedia.org/wiki/Vanishing_gradient_problem).

## Results for ReLU with L2 Regularization

Michael reports a classification accuracy of _99.23%_, using a learning rate of _0.03_, with the addition of an [_L2_ regularization](http://neuralnetworksanddeeplearning.com/chap3.html#regularization) term of _0.1_. I tried to replicate these results. However, with _0.1_ as the weight decay value, my results were significantly worse, hovering at around _85%_:

```python
>>> from pytorch_mnist_convnet import train_and_test_network, ConvNetTwoConvLayersReLU
>>> net = ConvNetTwoConvLayersReLU()
>>> train_and_test_network(net, lr=0.03, wd=0.1)
Test data results: 0.8531
```

After playing around a bit, I got much better results with weight decay set to _0.00005_:

```python
>>> from pytorch_mnist_convnet import train_and_test_network, ConvNetTwoConvLayersReLU
>>> net = ConvNetTwoConvLayersReLU()
>>> train_and_test_network(net, lr=0.03, wd=0.00005)
Test data results: 0.9943
```

Here we get _99.43%_, comparable to, and actually a bit better than Michael's reported value of _99.23%_.

## Expand the Training Data

Michael next brings up another technique that can be used to improve training - expanding the training data. He applies a very simple technique of just shifting each image in the training set over by a single pixel. This way, each image generates 4 additional images, shifted over to the right, left, up, and down respectively. The code below generates the expanded dataset ([common.py](https://github.com/nestedsoftware/pytorch/blob/master/common.py)):

```python
def identity(tensor):
    return tensor


def shift_right(tensor):
    shifted = torch.roll(tensor, 1, 1)
    shifted[:, 0] = 0.0
    return shifted


def shift_left(tensor):
    shifted = torch.roll(tensor, -1, 1)
    shifted[:, IMAGE_WIDTH-1] = 0.0
    return shifted


def shift_up(tensor):
    shifted = torch.roll(tensor, -1, 0)
    shifted[IMAGE_WIDTH-1, :] = 0.0
    return shifted


def shift_down(tensor):
    shifted = torch.roll(tensor, 1, 0)
    shifted[0, :] = 0.0
    return shifted


def get_extended_dataset(root="./data", train=True, transform=transformations,
                         download=True):
    training_dataset = datasets.MNIST(root=root, train=train,
                                      transform=transform, download=download)
    shift_operations = [identity, shift_right, shift_left, shift_up, shift_down]
    extended_dataset = []
    for image, expected_value in training_dataset:
        for shift in shift_operations:
            shifted_image = shift(image[0]).unsqueeze(0)
            extended_dataset.append((shifted_image, expected_value))
    return extended_dataset
```

## Results with Expanded Training Data

Continuing with the same network, Michael reports _99.37%_ accuracy using the extended data. Let's try it:

```python
>>> from pytorch_mnist_convnet import train_and_test_network, ConvNetTwoConvLayersReLU
>>> from common import get_extended_train_loader
>>> train_loader = get_extended_train_loader()
>>> net = ConvNetTwoConvLayersReLU()
>>> train_and_test_network(net, lr=0.03, wd=0.00005, train_loader=train_loader)
Test data results: 0.9951
```

We get _99.51%_, a modest improvement on the _99.43%_ accuracy we obtained without extending the data.

> Per Michael's book, a more sophisticated approach for algorithmically extending the training data is described in [Best practices for convolutional neural networks applied to visual document analysis](https://ieeexplore.ieee.org/document/1227801).

## Add Fully Connected Layer and Dropout

The last network we'll look at is [`double_fc_dropout`](https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/conv.py). We replace the single dense layer of _100_ neurons with two dense layers of _1,000_ neurons each. To reduce overfitting, we also add [dropout](http://neuralnetworksanddeeplearning.com/chap3.html#other_techniques_for_regularization). During training, dropout excludes some neurons in a given layer from participating both in forward and back propagation. In our case, we set a probability of _50%_ for a neuron in a given layer to be excluded.

Our PyTorch version is shown below ([pytorch_mnist_convnet.py](https://github.com/nestedsoftware/pytorch/blob/master/pytorch_mnist_convnet.py)):

```python
class ConvNetTwoConvTwoDenseLayersWithDropout(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(in_channels=1, out_channels=20, kernel_size=5)
        self.conv2 = nn.Conv2d(in_channels=20, out_channels=40, kernel_size=5)

        self.dropout1 = nn.Dropout(p=0.5)
        self.fc1 = nn.Linear(4*4*40, 1000)

        self.dropout2 = nn.Dropout(p=0.5)
        self.fc2 = nn.Linear(1000, 1000)

        self.dropout3 = nn.Dropout(p=0.5)
        self.out = nn.Linear(1000, OUTPUT_SIZE)

    def forward(self, x):
        x = self.conv1(x)
        x = torch.relu(x)
        x = torch.max_pool2d(x, kernel_size=2, stride=2)

        x = self.conv2(x)
        x = torch.relu(x)
        x = torch.max_pool2d(x, kernel_size=2, stride=2)

        x = x.view(-1, 4*4*40)
        x = self.dropout1(x)
        x = self.fc1(x)
        x = torch.relu(x)

        x = self.dropout2(x)
        x = self.fc2(x)
        x = torch.relu(x)

        x = self.dropout3(x)
        x = self.out(x)
        return x
```

## Final Results

Michael reports an improvement to _99.6%_ after _40_ epochs. Let's try it ourselves:

```python
>>> from pytorch_mnist_convnet import train_and_test_network
>>> from pytorch_mnist_convnet import ConvNetTwoConvTwoDenseLayersWithDropout
>>> from common import get_extended_train_loader
>>> train_loader = get_extended_train_loader()
>>> net = ConvNetTwoConvTwoDenseLayersWithDropout()
>>> train_and_test_network(net, num_epochs=40, lr=0.03, train_loader=train_loader)
Test data results: 0.9964
```

On a first try, I also obtained an improved result of _99.64%_ (compared to _99.51%_ previously). This result looks pretty good. However, I noticed that it wasn't very stable. After a few initial epochs of training, in subsequent epochs the accuracy on test data would fluctuate chaotically. I ran the training several times, and while the best result I got was _99.64%_, most of the time the final result was around _99.5%_.

The back-and-forth fluctuations in the results made me wonder if the learning rate was a bit too high. A learning rate of _0.005_ does seem to produce more stable and reliable results:

```python
>>> from pytorch_mnist_convnet import train_and_test_network
>>> from pytorch_mnist_convnet import ConvNetTwoConvTwoDenseLayersWithDropout
>>> from common import get_extended_train_loader
>>> train_loader = get_extended_train_loader()
>>> net = ConvNetTwoConvTwoDenseLayersWithDropout()
>>> train_and_test_network(net, num_epochs=40, lr=0.005, train_loader=train_loader)
Test data results: 0.9963
```

In the graph below, we can see in detail the improvement of this network for the training run shown above (after each training epoch, we switch the model to `eval` mode and try it against the test data):

![final network training progress](/assets/images/2019-09-09-pytorch-image-recognition-with-convolutional-networks-4k17.159805/jy1pkhoreratz7vktc0w.png)

## Code

The code for this article is available in full on github:

* [https://github.com/nestedsoftware/pytorch](https://github.com/nestedsoftware/pytorch)

## References:

* [Chapter 3](http://neuralnetworksanddeeplearning.com/chap3.html) of Neural Networks and Deep Learning, by Michael Nielsen
* [Chapter 6](http://neuralnetworksanddeeplearning.com/chap6.html) of Neural Networks and Deep Learning, by Michael Nielsen
* Michael Nielsen's Theano [network topologies](https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/conv.py) and [framework code](https://github.com/mnielsen/neural-networks-and-deep-learning/blob/master/src/network3.py)
* [Softmax](https://en.wikipedia.org/wiki/Softmax_function)
* [CrossEntropyLoss](https://pytorch.org/docs/stable/nn.html#crossentropyloss) in PyTorch
* [L2 Regularization](http://neuralnetworksanddeeplearning.com/chap3.html#regularization)
* [ReLU](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)) activation
* [Vanishing gradient problem](https://en.wikipedia.org/wiki/Vanishing_gradient_problem)
* [Best practices for convolutional neural networks applied to visual document analysis](https://ieeexplore.ieee.org/document/1227801)

## Related

* [Convolutional Neural Networks: An Intuitive Primer]({% link _posts/2019-05-28-convolutional-neural-networks-an-intuitive-primer-k1k.114570.md %})
