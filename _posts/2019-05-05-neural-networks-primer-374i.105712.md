---
title: Neural Networks Primer
published: true
cover_image: /assets/images/2019-05-05-neural-networks-primer-374i.105712/xudubj78tg9zab9j90ue.jpg
description: Overview of the structure, calculations, and code needed to implement a simple neural network from scratch
series: Neural Networks
canonical_url: https://nestedsoftware.github.io/2019/05/05/neural-networks-primer-374i.105712.html
tags: neural networks, machine learning, python, ai
---

In this article, I'd like to introduce the basic concepts required to implement a simple neural network from scratch. Even though this neural network is rather primitive by modern standards, it can still do something that's actually quite useful and impressive: It can be trained to accurately recognize handwritten digits between 0 and 9!

I recently went over a few different tutorials on the subject. While those tutorials were great, at the end of it I thought there was room to clarify some things a bit further. In addition to this primer, you may want to check out the following free resources as well:

* [Neural Networks](https://www.youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi), a youtube video series by [3Blue1Brown](https://www.youtube.com/channel/UCYO_jab_esuFRV4b17AJtAw) (Grant Sanderson)
* Chapters [one](http://neuralnetworksanddeeplearning.com/chap1.html) and [two](http://neuralnetworksanddeeplearning.com/chap2.html) of [Neural Networks and Deep Learning](http://neuralnetworksanddeeplearning.com/), by Michael Nielsen

## Neural Network Structure

The structure of our neural network is quite simple. The basic unit of the network is the _neuron_. Each neuron can have inputs from any number of neurons feeding into it. A neuron produces a single output value, which is called the _activation_ for that neuron. This activation value can in turn be sent as input to any number of other neurons.

The neurons are organized into _layers_. Each neuron in a given layer receives inputs from all of the neurons in the previous layer. The activation of a given neuron is also sent to all of the neurons in the next layer. The first layer is called the _input_ layer. The last layer is called the _output_ layer. Any layers in between are called _hidden_ layers, because they only affect the ultimate output of the network indirectly. We can think of this as an assembly line: The raw materials go into the input layer and the final product comes out the other end from the output layer. All of the intermediate steps involved in building the end product occur in the hidden layers. Below is a simple diagram showing the basic structure of a neural network:

![basic network diagram](/assets/images/2019-05-05-neural-networks-primer-374i.105712/v8iwotkuib7a8cpj6r9r.png)

> The network shown above has a single hidden layer, but there are often multiple hidden layers.

The edge connecting two neurons has two values associated with it. There's the activation of the sending neuron as well as a _weight_ assigned to that activation by the receiving neuron. The higher the weight, the more significantly the incoming activation will affect the receiving neuron's activation. A given neuron may receive inputs from many neurons, and each will have its own weight. Each neuron also has an additional value called the _bias_. The bias is a measure of how intrinsically active a neuron is. A high positive bias means that the neuron will tend to have a higher activation regardless of what inputs it receives. A high negative bias will act as a brake, significantly dampening the activation of the neuron.

For this example, we will restrict the activation of a given neuron to a value between 0 and 1. To accomplish this, we'll use the _sigmoid_ function. This function takes any positive or negative number as input and squashes it into a range between 0 and 1. Below is the diagram and formula for the sigmoid function:

![sigmoid formula and graph](/assets/images/2019-05-05-neural-networks-primer-374i.105712/oc3gisuu38512poxnc1p.png)

> Sigmoids were used early on in the history of neural networks, but they are not used very much any more. These days, something like a [ReLU](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)) function is more common.

Below we have the simplest case of a single neuron in layer _L_ feeding into a neuron in the next layer, _L+1_. To calculate the activation for the neuron in layer _L+1_, first we multiply the weight for that edge by the activation from the sending neuron, then we add the bias. This becomes a _raw activation_ value that we will call _z_ in this article. Lastly, we apply the sigmoid function to _z_ to obtain the actual activation, _a_, for the neuron in the next layer, _L+1_.

![basic activation](/assets/images/2019-05-05-neural-networks-primer-374i.105712/0y9ipg29bd57jg5sict9.png)

## Input and Output

Grant Sanderson calls recognizing the mnist numbers the _hello world_ of neural networks. The input images come from the [mnist database](https://en.wikipedia.org/wiki/MNIST_database). Each mnist image is a _28 x 28_ grid of pixels. Each pixel is a decimal number between 0 and 1 and represents a greyscale value. The image below of a _6_ is an example of what an mnist image looks like:

![mnist image of a 6](/assets/images/2019-05-05-neural-networks-primer-374i.105712/patvd4i2m5iors703i25.png)

To supply these values as inputs into the network, we simply line up all of the pixels into a single column, and assign the greyscale value for each pixel to a corresponding input neuron. That means we need _28 x 28_, or _784_ input neurons.

To clarify, see the diagram below of the number _2_ represented as a simple _6x6_ grid. The real mnist images have greyscale values, but in this example the cells are either black or white (0 or 1). To generate an input layer, we assign the first row of pixels as input neurons, then the next row below that, and so on. The end result is that our input is represented by 36 neurons:

![pixels to network](/assets/images/2019-05-05-neural-networks-primer-374i.105712/s9mpgmw0bfouu4nun68k.png)

Our network for recognizing handwritten digits uses 10 output neurons, each with values between 0 and 1. We want the output neuron corresponding to the correct digit to light up with a value close to 1 and for all of the other neurons to be as close to 0 as possible. If our image represents the digit _4_, that means we want our output neurons to indicate something close to _[0, 0, 0, 0, 1, 0, 0, 0, 0, 0]_.

> Why do we use 10 output neurons? After all, we could compress the output. For example, in binary we could encode the digits from 0 to 10 with 4 neurons. This would work, but it seems as though simplifying the output, so that each output neuron has only a single meaning, makes it easier for the network to learn. Conceptually, it means that when we tug to increase or decrease the activation for an output neuron, there is only one meaning to it.

The diagram below shows an overview of the neural network that's actually used in Michael Nielsen's book to recognize the mnist images:

![mnist network](/assets/images/2019-05-05-neural-networks-primer-374i.105712/4rwsuffvzzk7046yy1ud.png)
> _image credit: Michael A. Nielsen, "Neural Networks and Deep Learning", Determination Press, 2015_

## Gradient Descent

The key idea behind neural networks is _gradient descent_. What is gradient descent? Let's say you're taking a walk in a lush green region of hills and meadows. Suppose you're at the top of a hill and you want to get down into the valley. However, you've been blindfolded, so you can't see where you're going. How can you get to the bottom? A simple approach is simply to slowly spin around in place, and feel with your feet to find the steepest part of the hill at your current location, then to take a small step downward along that slope. From there you can again feel around for what seems to be the steepest downward slope, and take another small step in that direction, and so on. Eventually you'll reach a flat region where the slope has tapered off. This method doesn't guarantee that you will find the best path into the valley, but it does make sure that each step is the best move locally relative to where you are at that point in time.

In a nutshell, this is the gradient descent approach used by neural networks! It's really that simple. Every problem that neural networks solve, whether it's image and speech recognition, or playing the game of go, or predicting the stock market, is ultimately represented as some function with a very large number of variables. We can intuitively think of it as a huge (multi-dimensional) landscape. The job of the neural network becomes to iterate over a large amount of data in order to tune those variables so that it can move _downward_ along the slope of this very complicated function.

## Partial Derivatives and Gradients

Let's explore this idea of gradient descent with some simple math. Let's say we have a function _f_ over a single variable _x_. As we adjust the variable _x_, the value of the function, _f(x)_, changes accordingly.

If we're at some point _x_ right now, how can we take a step downward along this function? We can calculate the local slope of the function by taking the _derivative_ of _f_ with respect to _x_. If the derivative, _∂f(x)/x_, is positive, that means the function is trending upward. If the derivative is negative, it means the function is trending downward. We can therefore calculate our step in the downward direction with the following pseudo code, where `step_size` is a small increment value that we've chosen ahead of time:

`step = ∂f(x)/x * step_size`

`x = x - step`

* If `∂f(x)/x` is positive, then `step` will also be positive. Therefore subtracting `step` from `x` will make `x` smaller. A smaller `x` will cause _f(x)_ to be smaller as well. In other words, we're moving downhill.
* If the derivative is negative, then `step` will also be negative. Subtracting a negative value is the same as adding a positive value, so in this case `x` will increase. Since the slope is negative, increasing `x` will cause us to go downhill.

Therefore `x = x - step` will help us to go downhill regardless of whether the slope is positive or negative. If the slope becomes 0, then we've reached a flat region. This is called a _local minimum_ of the function.

> The notation _∂f(x)/x_ tells us that if we make a small change to _x_, it will have have a certain effect on _f(x)_. If this value is very high (either in the positive or negative direction), that means the slope is steep. A small step in the _x_ direction will cause us to take a big step up or down the function. If the value is close to 0, it means the slope is relatively flat, so a step in the _x_ direction won't change our elevation very much.
>
> Choosing a good value for `step_size` depends on the problem at hand. Making it too small will tend to slow down the network's learning, but making it too big could potentially mean that a single step takes us to a higher point in the function, instead of going downward, which is also undesirable. Because of its effect on learning, `step_size` is often called the _learning rate_ in neural network terminology. It's a [_hyperparameter_](https://en.wikipedia.org/wiki/Hyperparameter_(machine_learning)). The term hyperparameter sounds complicated, but it simply means that learning rate is a parameter that has to be manually tuned rather than being refined by the network itself as it learns. Any parameter that we select for our neural network that doesn't then get fine-tuned by the network's learning process is called a hyperparameter. We can think of the hyperparameters as dials and knobs that we can tweak prior to starting the learning process. These are values that will affect the learning process of the network, but the feedback loop of training the network won't alter these parameters. They stay the same unless we manually adjust them.

We've looked at a function of a single variable _x_. Such functions can be viewed as graphs in 2 dimensions, with one axis for _x_ and one for _f(x)_, like in the diagram below:

![gradient descent](/assets/images/2019-05-05-neural-networks-primer-374i.105712/xiajndqd37l4ilx4lrw9.png)

 If we increase the function to 2 variables, _f(x,y)_, then we need one axis for each of _x_ and _y_ to represent the inputs, and the function can therefore be viewed as a graph in 3 dimensions. The slope of this function also becomes a vector in 3 dimensions. We can decompose this vector into two component vectors, the slope along the _x_ axis and the slope along the _y_ axis. These two values, _∂f(x,y)/x_, and _∂f(x,y)/y_, are called the _partial derivatives_ of the function with respect _x_ and _y_. In other words, _∂f(x,y)/x_ tells us how much _f(x,y)_ will change if we make a small adjustment to _x_ and leave _y_ unchanged. Conversely, _∂f(x,y)/y_ tells us how _f(x,y)_ will change if we make a small adjustment to _y_ while leaving _x_ the same. The list of the partial derivatives, _[∂f(x,y)/x, ∂f(x,y)/y]_, is called the _gradient_ of the function. It defines the slope of the function in the direction of _steepest descent_, in the sense that adding these partial derivative vectors together produces the overall gradient vector.

This idea also applies to functions with a larger number of parameters, _f(x,y,z,...)_. In fact, that's precisely how neural networks operate. We can't directly visualize such functions, but we can use the same mathematical tools to get the gradient. To move _downward_ along such a gradient with our small steps, we apply the same trick of subtracting from each variable the partial derivative with respect to that variable times some small step size. The adjusted values for each axis will result in a smaller _f(x,y,z...)_. In other words, this moves the function _downward_ along the steepest path of descent relative to its current location. When we look at the math that accomplishes this later on, I think it's helpful to keep in mind that, at a high level, this is all that's happening.

## Activation

Let's calculate the outputs for our network. We've already seen how to calculate the activation for a neuron that has only a single input. When a neuron has multiple neurons feeding into it, we add up the weighted activations from the incoming neurons first, then we add the bias, and finally we apply our sigmoid function. In other words, all of the incoming activity affects how active our neuron becomes. Let's say we have a neuron in layer _L+1_ with 2 neurons feeding into it, as in the diagram below:

![simple activation calculation](/assets/images/2019-05-05-neural-networks-primer-374i.105712/zsuwj0j4gxsnfdlvujlu.png)

> The superscripts _L_ and _L+1_ are _not_ exponents. They just signify which layer of the network the value belongs to. Please do keep in mind that (almost) any time you see superscripts in this article, they do _not_ denote an exponent! The only exceptions are the sigmoid function and its derivative, and the _2_ used as the exponent for the quadratic cost function.

We can see that we add the weighted activations from the pink and orange neurons and add the bias of the blue neuron to produce the raw activation for the blue neuron, _z_: _z = w<sub>0,0</sub><sup>L+1</sup>a<sub>0</sub><sup>L</sup> + w<sub>0,1</sub><sup>L+1</sup>a<sub>1</sub><sup>L</sup> + b<sub>0</sub><sup>L+1</sup>_. Then we apply the sigmoid function to obtain the activation: _a = σ(z)_.

It turns out that we can express this calculation neatly using matrices. Let's index the neurons in layer _L+1_ with _j_, and the neurons in the previous layer _L_ with _k_. _J_ will denote the total number of neurons in layer _L+1_ and _K_ will denote the total number of neurons in layer _L_.

> This ordering of _j_ and _k_ may look backwards but we'll see why we use this indexing scheme in a moment.

Let's consider a simple neural network with two layers. The first layer, _L_, has 2 neurons and the second layer, _L+1_, has 3 neurons:

![2x3 network activations](/assets/images/2019-05-05-neural-networks-primer-374i.105712/063o18p485i8ba6v3pvm.png)

We want the activations for layer _L+1_ to be a _3x1_ matrix, that is, a matrix with 3 rows in a single column. The value in each row will represent the activation for the corresponding neuron in that layer. To get our results into the appropriate form, we can define the needed matrices as follows:

* First, we define a matrix _w<sup>L+1</sup>_ for the weights coming into layer _L+1_ as a _JxK_ matrix. The first row of this matrix will contain each of the weights coming into the first neuron in layer _L+1_; the second row will have each of the weights coming into the second neuron in layer _L+1_, and so on.

* Next, we group the activations in layer _L_ into a _Kx1_, single-column matrix, _a<sup>L</sup>_. The first row has the activation coming from the first neuron in layer _L_; the second row has the activation coming from the second neuron in layer _L_, and so on.

* Lastly we place the biases for the neurons in layer _L+1_ into a _Jx1_, single-column matrix, _b<sup>L+1</sup>_. The first row has the bias for the first neuron in layer _L+1_; the second row has the bias for the second neuron in layer _L+1_, etc.

We can see that taking the dot product of _w<sup>L+1</sup> ⋅ a<sup>L</sup>_ produces a _Jx1_ matrix. We can add that matrix to _b<sup>L+1</sup>_, also _Jx1_, which produces a _Jx1_ matrix _z<sup>L+1</sup>_ that has all of the raw activation values for layer _L+1_. Finally we can just pass each of the values in _z<sup>L+1</sup>_ to σ to obtain a matrix _a<sup>L+1</sup>_ of the activations for layer _L+1_.

We can see that we need to arrange the weights matrix _w_ for a given layer _L+1_ such that each row corresponds to the edges coming into a given neuron in layer _L+1_. This makes intuitive sense, since the activation for a neuron in _L+1_ depends on all of the inputs coming in from the previous layer. That's why we use _j_ to index the neurons in the next layer and _k_ to index the neurons in the previous layer, because we want the weights matrix to be a _JxK_ matrix. That way, the dot product will work out to produce the correct shape for the _z_ and _a_ matrices. If we did the indexing the other way around, our weights matrix would be a _KxJ_ matrix. That would be fine too, since the meaning of the rows and columns wouldn't change, just the nomenclature. Below are the matrix calculations needed to compute _z<sup>L+1</sup>_ and _a<sup>L+1</sup>_:

![z with dot product](/assets/images/2019-05-05-neural-networks-primer-374i.105712/gvenjrz3x2dve0x165p8.png)

![a with dot product](/assets/images/2019-05-05-neural-networks-primer-374i.105712/53750bhjin7i1ot0j254.png)

> Calculating the [dot product](https://www.mathsisfun.com/algebra/matrix-multiplying.html) of two matrices is fairly simple. The two matrices must have the form _I x J_ and _J x K_ such that the result becomes an _I x K_ matrix. In other words, the number of columns for the matrix on the left must match the number of rows for the matrix on the right. The dot product becomes a matrix with the same number of rows as the matrix on the left and the same number of columns as the matrix on the right.

## Cost Function

In order for the network to learn, we need to provide feedback about whether the current network performed well for a given training input. This is done by using a _cost function_. The cost function compares the network's actual output against the correct value. We may have multiple neurons in the output layer. In that case we need to compare the correct values for each of the output neurons against each actual output. For this example, we'll use a simple function called the _quadratic cost function_:

![Cost function](/assets/images/2019-05-05-neural-networks-primer-374i.105712/p2vnx25v2bztb3vaxns7.png)

> As far as I can tell, the extra division by 2 is mostly there to cancel the factor of 2 that we obtain when we take the derivative of this function. In any case, this constant factor should not significantly affect how the network learns.

If our network only has a single output neuron, then the cost can be calculated by subtracting the correct value from the output value, and then squaring that result. If we have multiple output neurons, like the 10 neurons in our mnist number recognition network, then we can treat _a<sup>L</sup>_, the actual output, and _y_, the correct values, as single column matrices. In that case, we subtract these two matrices. This amounts to performing the same subtraction for each row of the resulting matrix. We subtract the expected value for each given neuron from its corresponding actual output, then square the result.

For a given value of _a_ and _y_, if we map these as points on a line, we can see that _a - y_ is the distance between the two points, so the cost function is the square of this distance. There are other [cost functions](https://stats.stackexchange.com/questions/154879/a-list-of-cost-functions-used-in-neural-networks-alongside-applications) that are used in machine learning as well.

## Backpropagation

We want to adjust the weights and the biases in our network such that, over time, the training data will yield a lower and lower cost. To do so, we'll need to figure out the slope of the cost function with respect to these weights and biases. Then we can use gradient descent to move down this slope in small steps for each feedback loop of the network.

Let's consider a minimalistic scenario where we have a single output neuron with a single neuron feeding into it from a hidden layer. It turns out that the equations we derive for this trivial case are easy to adapt to the more general case of multiple neurons per layer.

In the diagram below, we can see that the cost, _C_, for the output depends directly on the activation _a<sup>L</sup>_ and on the expected value for that input, _y_. In turn, _a<sup>L</sup>_ depends on the raw activation, _z<sup>L</sup>_. Lastly, _z<sup>L</sup>_ depends on 3 variables: The bias, _b<sup>L</sup>_, the weight, _w<sup>L</sup>_, and the incoming activation, _a<sup>L-1</sup>_:

![Diagram of cost function breakdown](/assets/images/2019-05-05-neural-networks-primer-374i.105712/enp0kqgtxreujcq11ett.png)

We will use this information to figure out the derivative of the cost function with respect to the weight and bias. We will also determine the derivative of the cost with respect to the activation of the neuron in the previous layer. You may wonder why we'd need to determine the cost function relative to the activation in the previous layer. After all, we can't directly adjust it. That is indeed true, we can't modify a neuron's activation directly. However, we will be able to use the gradient with respect to the activation in the previous layer to calculate the needed changes to the weights and biases for that previous layer, and so on, moving backward through the network. This is why we call this step of adjusting all of the weights and biases _backpropagation_.

Let's first calculate the derivative of the cost function with respect to the activation of the output neuron. This is quite simple. The derivative is just a linear function:

![Partial c wrt a](/assets/images/2019-05-05-neural-networks-primer-374i.105712/8qu5iih2ieehp02orwv8.png)

Since _a<sup>L</sup>_ depends on _z<sup>L</sup>_, let's also figure out the slope of _a_ with respect to _z_:

![Partial a wrt z](/assets/images/2019-05-05-neural-networks-primer-374i.105712/tl3iq2ufcdpsfi0fkmke.png)

> The derivative of the sigmoid function is: ![sigmoid prime](/assets/images/2019-05-05-neural-networks-primer-374i.105712/8d6obz9u9hgvt9zuyi22.png)

_z<sup>L</sup>_ depends on the incoming activation from the previous layer, _a<sup>L-1</sup>_, the weight for that activation, _w<sup>L</sup>_, and the current bias, _b<sup>L</sup>_. Let's compute the partial derivatives of _z_ with respect to each of these inputs:

![Partial z wrt bwa-1](/assets/images/2019-05-05-neural-networks-primer-374i.105712/ffar3pkbjxorxseebb6w.png)

Now that we have all of the partial derivatives we need, we can use the [chain rule](https://en.wikipedia.org/wiki/Chain_rule) to compute the 3 equations we'll need to do backpropagation for our network: The partial derivative of the cost function with respect to the weight, the bias, and the previous layer's activation:

![Cost partials using chain rule](/assets/images/2019-05-05-neural-networks-primer-374i.105712/vb4l5jo23rgxtirhga54.png)

The idea is that we can calculate _∂C/∂a<sup>L-1</sup>_ using the values of _w<sup>L</sup>_ and _∂C/db<sup>L</sup>_. Once we have _∂C/∂a<sup>L-1</sup>_, we can use it to calculate _∂C/db<sup>L-1</sup>_ and _∂C/dw<sup>L-1</sup>_. From there we just keep repeating the same steps backward through the layers of our network until we reach the input layer, hence the term _backpropagation_.

## Example Calculation

Let's compute a single learning iteration for a small network with a single input neuron, one middle neuron, and a single output neuron. We'll set the input to _0.8_. The expected output, _y_, is 1 for this input. The weights and biases are in the diagram below:

![Sample calculation](/assets/images/2019-05-05-neural-networks-primer-374i.105712/7xbmlv7qpot4zvrioaxf.png)

First we need to calculate the raw activations _z_ as well as the activations _a_ for the network. We use the following (python) functions for `z`, `a`, and `sigmoid`:

```python
import numpy as np

def sigmoid(z):
    return 1.0/(1.0+np.exp(-z))

def z(w, a, b):
    return w * a + b

def a(z):
    return sigmoid(z)
```

For layer _L1_, we can calculate the value of `z` and `a` as follows:

```python
>>> a_l0 = 0.8
>>> w_l1 = 1.58
>>> b_l1 = -0.14
>>> z_l1 = z(w_l1, a_l0, b_l1)
>>> a_l1 = sigmoid(z_l1)
>>> z_l1
1.124
>>> a_l1
0.7547299213576082
```

Now that we have the activation for layer _L1_, we can use it to calculate `z` and `a` for layer _L2_:

```python
>>> b_l2 = -0.11
>>> w_l2 = 2.45
>>> z_l2 = z(w_l2, a_l1, b_l2)
>>> a_l2 = sigmoid(z_l2)
>>> z_l2
1.73908830732614
>>> a_l2
0.850571226530534
```
Great, now we've got our activation for _L2_. We now need to calculate the slope of the cost function with respect to three variables, the bias, the weight, and the activation from the previous layer. The equations for the partial derivatives, as well as the derivative of the sigmoid function, `sigmoid_prime` are below:

```python
def sigmoid_prime(z):
    return sigmoid(z)*(1-sigmoid(z))

def dc_db(z, dc_da):
    return sigmoid_prime(z) * dc_da

def dc_dw(a_prev, dc_db):
    return a_prev * dc_db

def dc_da_prev(w, dc_db):
    return w * dc_db
```

We calculate these partial derivatives below:

```python
>>> dc_da_l2 = a_l2-1
>>> dc_db_l2 = dc_db(z_l2, dc_da_l2)
>>> dc_dw_l2 = dc_dw(a_l1, dc_db_l2)
>>> dc_da_l1 = dc_da_prev(w_l2, dc_db_l2)
>>> dc_db_l2
-0.018992369482903983
>>> dc_dw_l2
-0.014334109526226761
>>> dc_da_l1
-0.04653130523311476
```

Now that we have the slope of the cost function with respect to the bias `b_l2` and the weight `w_l2`, we can update those biases and weights:

```python
>>> step_size = 0.1
>>> updated_b_l2 = b_l2 - dc_db_l2 * step_size
>>> updated_w_l2 = w_l2 - dc_dw_l2 * step_size
>>> updated_b_l2
-0.1081007630517096
>>> updated_w_l2
2.451433410952623
```

Having adjusted the weight and bias for the _L2_ layer, we can do the same thing for the _L1_ layer. We've calculated `dc_da_l1`, which is the slope of the cost function with respect to the activation coming from the previous layer. To obtain the gradient for the bias and weight for the _L1_ layer, we just continue using the chain rule as before. In the _L2_ layer, `dc_da_l2` was `a_l2-y`. For the _L1_ layer, we've just calculated `dc_da_l1`, so we can use that now to get the slope of the cost function with respect to the bias at _L1_, `dc_db_l1`. Then we proceed as before, using `dc_db_l1` to calculate `dc_dw_l1`.

```python
>>> dc_db_l1 = dc_db(z_l1, dc_da_l1)
>>> dc_dw_l1 = dc_dw(a_l0, dc_db_l1)
>>> dc_db_l1
-0.008613534018377424
>>> dc_dw_l1
-0.006890827214701939
```
Again, we use these partial derivatives to adjust the weight and bias for L1:

```python
>>> updated_b_l1 = b_l1 - dc_db_l1 * step_size
>>> updated_w_l1 = w_l1 - dc_dw_l1 * step_size
>>> updated_b_l1
-0.13913864659816227
>>> updated_w_l1
1.5806890827214704
```
We don't need to go further, since the layer _L0_ is the input layer, which we can't adjust. Let's calculate the new activations using our updated weights and biases:

```python
>>> updated_z_l1 = z(updated_w_l1, a_l0, updated_b_l1)
>>> updated_a_l1 = sigmoid(updated_z_l1)
>>> updated_z_l1
1.125412619579014
>>> updated_a_l1
0.7549913210309638
>>> updated_z_l2 = z(updated_w_l2, updated_a_l1, updated_b_l2)
>>> updated_a_l2 = sigmoid(updated_z_l2)
>>> updated_z_l2
1.7427101863028525
>>> updated_a_l2
0.8510309824120517
```

Finally let's compare the cost function for our original activation with the one we obtain using our new activation. We'll use the following as our cost function:

```python
def cost(a, y):
    return 0.5 * (a - y)**2
```

The original cost and the updated cost are:

```python
>>> original_cost = cost(a_l2, 1)
>>> updated_cost = cost(updated_a_l2, 1)
>>> original_cost
0.011164479170294499
>>> updated_cost
0.011095884100559231
```
We can see that the `updated_cost` is indeed slightly lower than the `original_cost`!

## Multiple Neurons per Layer

When we have a network with multiple neurons per layer, our quantities like _w_, _b_, _z_, and _a_, become matrices rather than scalar values. In order to accommodate that, we need to make some adjustments to the equations that we use for the partial derivatives. The nice thing is that the new form of the equations is pretty intuitive. We can figure out the form of the equations just by imagining the shape of the matrix we want the result to have.

Let's consider a simple multi-layer network like the one below. You can see the shape of the various matrices of interest for each layer:

![2x3x2 network](/assets/images/2019-05-05-neural-networks-primer-374i.105712/d8p5h3x9703tl570f4us.png)

> Keep in mind that the superscripts all denote the current layer. They are _not_ exponents.

Since we know that each bias will be updated using a partial derivative, we need to have a partial derivative value corresponding to each bias. Therefore the partial derivative of the cost with respect to the biases in the current layer, _∂C/∂b_, should have the same shape as the biases matrix for that layer.

In our example, the output layer has 2 neurons, so the biases matrix, _b_, for that layer is a _2x1_ matrix. Therefore _∂C/∂b_ for that layer should be a 2x1 matrix as well. From the equations we derived earlier, we know _∂C/∂b_ requires us to multiply the value of _(a-y)_ and _σ'(z)_. Both of these are _2x1_ matrices, so all we need to do is to multiply the value of _σ'(z)_ for each neuron by the difference _(a-y)_ for that same neuron. Intuitively this makes sense: Each value in _(a-y)_ matches up with its corresponding _σ'(z)_ value. When a given value is related to a bunch of incoming or outgoing values, we use the dot product, but here it's a simple 1:1 relationship. This kind of simple product of two identical matrices is called the [_hadamard product_](https://en.wikipedia.org/wiki/Hadamard_product_(matrices)). We represent it as a dot surrounded by a circle. Below is the matrix form of the equation for _∂C/∂b_:

![dc_db matrix form](/assets/images/2019-05-05-neural-networks-primer-374i.105712/tng28gku5fyv9dw2xpfp.png)

Now let's turn our attention to _∂C/∂w_. In our output layer, the weights matrix, _w_, is a _2x3_ matrix. Therefore we want _∂C/∂w_ to be a 2x3 matrix as well. _∂C/∂w_ for the current layer is the product of _∂C/∂b_ for the current layer and the activation matrix _a_ for the previous layer. For our output layer, _∂C/∂b_ is a _2x1_ matrix. _a_ for the previous layer is a _3x1_ matrix. We can't multiply a _2x1_ and a _3x1_ matrix together directly. However, we can transpose _a_ to convert it into a _1x3_ matrix! Now the multiplication, using the dot product, produces a _2x3_ matrix. That matches up with the shape of _w_ matrix for this layer, so it works. Below is the math notation showing how we obtain _∂C/∂w_ in matrix form:

![dc_dw matrix form](/assets/images/2019-05-05-neural-networks-primer-374i.105712/3vyplo1hhbs7r721jgbf.png)

Lastly, we need to calculate _∂C/∂a<sup>L-1</sup>_. _a<sup>L-1</sup>_ is a _3x1_ matrix, so we want _∂C/∂a<sup>L-1</sup>_ to be a _3x1_ matrix too. We know that we need to somehow multiply _∂C/∂b_ against _w_, the weight matrix for the current layer. _∂C/∂b_ is a _2x1_ matrix and _w_ is a _2x3_ matrix. How can we arrange these as a product to obtain a _3x1_ matrix? We can first transpose _w_ to get a _3x2_ matrix. Now we can take the dot product of _w<sup>T</sup>_, a _3x2_ matrix, and _∂C/∂b_, a _2x1_ matrix, which gives us the _3x1_ matrix that we want. The equation is in the diagram below:

![dc_da_prev matrix form](/assets/images/2019-05-05-neural-networks-primer-374i.105712/8e218lhhqvj86d6zh2cv.png)

This last matrix represents the slope of the cost function with respect to the activation in the previous layer. This is very helpful, as we can use this value to calculate the slope with respect to the biases, _∂C/∂b_, and weights, _∂C/∂w_ in that previous layer. Those values can in turn be used to calculate _∂C/∂a<sup>L-2</sup>_, and so on. We continue performing the same operations, layer by layer, until we reach the input layer. Recall that we don't calculate any partial derivatives for the input layer since that's not something that the network adjusts

> If you want to build intuition around why we transpose _w_ and then do the dot product, I find it helpful to think of it this way: When we calculate the activation matrix for a given layer, we calculate the dot product of the weight matrix for that layer and the activation matrix from the previous layer. This makes sense, because for each neuron in the _next_ layer, it needs to pull together the weighted activations from _all_ of the neurons in the previous layer. We can think of _∂C/∂a<sup>L-1</sup>_ as the other side of that coin. When we make a small adjustment to the activation of a neuron in the current layer, it will affect the cost function along multiple paths. Let's say we adjust the activation of a single neuron, which connects to 3 neurons in the next layer. We need to add up the effect on the cost function of the sending neuron to the first receiving neuron, the second receiving neuron, and to the third receiving neuron.  That will be the first row of our resulting matrix (and so on for each of the other neurons in the sending layer). So, we need to have a matrix where each row represents the cumulative effect of a change in activation by a neuron in the previous layer on _each_ neuron in the next layer.

This method lets us calculate adjustments for the weights and biases in each layer of our network, propagating backward from the output layer. Once that process is done for a given input, we can say that our network has completed a training step. By performing this training for a large number of inputs, we can steadily tune the parameters of our network until it can do cool things like recognizing the mnist images!

The diagram below shows our example network with the partial derivatives for the output layer and middle layer:

![2x3x2 network partial derivatives](/assets/images/2019-05-05-neural-networks-primer-374i.105712/mozlq1exx8hjjbwewkb3.png)

> Keep in mind that the superscripts all denote the current layer. They are _not_ exponents.

I've written my own very simple implementation of this neural network in python. I've tried to remove all extraneous details, and to show only the code needed to feed forward the activations, and then to adjust the weights and biases, one training input at a time:

```python
import numpy as np

placeholder = np.array([[]])

class Network:
    def __init__(self, layers, **kw):
        self.num_layers = len(layers)
        self.b = [placeholder]
        self.w = [placeholder]

        if "b" in kw:
            b = kw.get("b")
            self.b += b

        if "w" in kw:
            w = kw.get("w")
            self.w += w

        num_neurons_prev_layer = layers[0]
        for num_neurons_current_layer in layers[1:]:
            if not "b" in kw:
                b = np.random.randn(num_neurons_current_layer, 1)
                self.b.append(b)

            if not "w" in kw:
                w = np.random.randn(num_neurons_current_layer, num_neurons_prev_layer)
                self.w.append(w)

            num_neurons_prev_layer = num_neurons_current_layer

    def feed_forward(self, inputs):
        self.z = [placeholder]
        self.a = [np.asarray([inputs]).transpose()]

        for l in xrange(1, self.num_layers):
            b = self.b[l]
            w = self.w[l]
            a_prev = self.a[l-1]

            z = raw_activation(w, a_prev, b)
            a = sigmoid(z)

            self.z.append(z)
            self.a.append(a)

    def propagate_backward(self, y, step_size):
        y = np.asarray([y]).transpose()

        output_layer = self.num_layers-1
        z = self.z[output_layer]
        a = self.a[output_layer]

        activations_gradient = a - y
        biases_gradient = dc_db(z, activations_gradient)

        a_prev = self.a[output_layer-1]
        weights_gradient = dc_dw(a_prev, biases_gradient)

        w = self.w[output_layer]
        activations_gradient = dc_da_prev(w, biases_gradient)

        self.b[output_layer] -= biases_gradient * step_size
        self.w[output_layer] -= weights_gradient * step_size

        for l in xrange(self.num_layers-2, 0, -1):
            z = self.z[l]
            biases_gradient = dc_db(z, activations_gradient)

            a_prev = self.a[l-1]
            weights_gradient = dc_dw(a_prev, biases_gradient)

            w = self.w[l]
            activations_gradient = dc_da_prev(w, biases_gradient)

            self.b[l] -= biases_gradient * step_size
            self.w[l] -= weights_gradient * step_size

def sigmoid(z):
    return 1.0/(1.0+np.exp(-z))

def sigmoid_prime(z):
    return sigmoid(z)*(1-sigmoid(z))

def raw_activation(w, a, b):
    return np.dot(w,a) + b

def dc_db(z, dc_da):
    return sigmoid_prime(z) * dc_da

def dc_dw(a_prev, dc_db):
    return np.dot(dc_db, a_prev.transpose())

def dc_da_prev(w, dc_db):
    return np.dot(w.transpose(), dc_db)

# demo:
b = [np.array([[0.54001045],
               [0.75958375],
               [0.01870296]]),
     np.array([[-0.32783478],
               [ 0.06061246]])]

w = [np.array([[-0.11499179,  0.454649  ],
               [-0.65801895,  0.56618695],
               [-0.15686814, -0.87499479]]),
     np.array([[ 0.01071228, -0.49139708, -0.81775586],
               [-0.87455946, -0.08351883, -0.77534763]])]

n = Network([2,3,2], b=b, w=w)

inputs = [0.8,0.2]
n.feed_forward(inputs)

y = [0, 1]
n.propagate_backward(y, 0.1)
```

> Note that we normally randomize the initial values of the weights and biases. This is a simple-minded way to create a fairly chaotic initial cost function with ample room for gradient descent. We wouldn't want to risk setting these variables in some predictable way, which might place the cost function into a flat plane from the very start!

Consider that this code is basically sufficient to recognize handwritten images of mnist numbers with a success rate of about 95%!  That's quite remarkable. Imagine how much effort it would take to develop a custom algorithm to do the same thing. I think it would be incredibly hard to get to the same level of accuracy that way, but we can achieve pretty good results with the very naive implementation above: All we have are layers of neurons connected together in a completely generic way, with maybe 100 lines of code to perform the forward and backward propagations!

## Stochastic Gradient Descent

Adjusting all of the weights and biases for every single input, as in the above code, can be slow. A common speedup technique is to run a batch of inputs through the network and to treat that as a single training step. In other words, first we calculate our partial derivatives for a bunch of randomly selected training inputs. We keep adding the most recent partial derivatives to each gradient matrix. Once we've done that, we divide each of these cumulative partial derivatives by the number of samples in the batch. We then update the weights and biases just once against this average slope. We can then continue doing the same thing with another batch of inputs. This is called _stochastic gradient descent_. Intuitively, this means our movements down the slope of the landscape are a bit more jerky than they would be otherwise. If we adjusted all of the parameters after every input, our path downward would be a smoother curve, but it would take longer to compute.

## MNIST Image Recognition

Michael Nielsen's [python code](https://raw.githubusercontent.com/mnielsen/neural-networks-and-deep-learning/master/src/network.py) ([github](https://github.com/mnielsen/neural-networks-and-deep-learning))for recognizing mnist images easily reaches approximately a 95% recognition rate after training for just a few minutes on a commodity PC. The following script runs the network with a single hidden layer of 30 neurons (run.py):

```python
import mnist_loader
import network

training_data, validation_data, test_data = mnist_loader.load_data_wrapper()

net = network.Network([784, 30, 10])
net.SGD(training_data, 30, 10, 3.0, test_data=test_data)
```

The results below show that the network achieves close to 95% accuracy:

```
C:\Dev\python\neural-networks-and-deep-learning\src>python run.py
Epoch 0: 9032 / 10000
...
Epoch 29: 9458 / 10000
```
If we change the network to 2 hidden layers of 16 neurons each, like in Grant Sanderson's video (run2.py):

```python
import mnist_loader
import network

training_data, validation_data, test_data = mnist_loader.load_data_wrapper()

net = network.Network([784, 16, 16, 10])
net.SGD(training_data, 30, 10, 3.0, test_data=test_data)
```

The results seem to be about the same:

```
C:\Dev\python\neural-networks-and-deep-learning\src>python run2.py
Epoch 0: 8957 / 10000
...
Epoch 29: 9385 / 10000
```
If we omit the hidden layer completely and just send our input layer directly to the output layer, the accuracy falls quite a bit, down to 75%.

In his video, Grant Sanderson speculates a bit about what the different layers might mean conceptually. He tosses out the idea that the first hidden layer might identify the parts of basic units of handwritten numbers. For example, it might break down an "o" loop into several parts. The second hidden layer might then put these individual parts together, e.g. A _9_ might be an "o" loop and a line or curved tail sticking out of it.

However, Grant found that examining the hidden layers didn't reveal anything so clear-cut, just rather noisy data that only shows hints of a pattern. This suggests that this neural network doesn't have to find minima that make sense to us as human beings. It seems to find local minima that are just good enough to do a pretty decent job of solving the problem, but these minima don't fully encapsulate what the numbers mean. That is, as Grant puts it, _in the unfathomably large 13,000 dimensional space of weights and biases, our network found itself a happy little local minimum that, despite successfully classifying most images, doesn't exactly pick up on the patterns we might have hoped for... Even if this network can recognize digits pretty well, it has no idea how to draw them._ One outcome of this fact is that our particular network will just as confidently classify an image of random pixels as it does a real mnist image!

Our simple network clearly has limitations. For example, the hidden layers don't seem to have any clear pattern or meaning. Also, with large numbers of neurons in each layer, having each of the neurons in one layer connected to all of the neurons in the next layer can become a performance problem. It's also a bit odd after all, isn't it, that all of our input neurons are treated the same, whether they're close together or on opposite sides of the image!

These are issues that are dealt with in some of the more sophisticated approaches to neural networks that have been developed over time. If you'd like to go deeper, check out further developments like [deep learning](https://en.wikipedia.org/wiki/Deep_learning), [convolutional neural networks](https://en.wikipedia.org/wiki/Convolutional_neural_network), [recurrent neural networks](https://en.wikipedia.org/wiki/Recurrent_neural_network), and [LSTM networks](https://en.wikipedia.org/wiki/Long_short-term_memory). With all that being said, a great thing about the simple network we've worked through in this article is that it can already do something useful and it's pretty easy to understand!
