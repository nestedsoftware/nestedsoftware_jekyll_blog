---
title: PyTorch Hello World
published: true
cover_image: /assets/images/2019-08-15-pytorch-hello-world-37mo.156165/muie09ovdv9s5qaqvhov.jpg
description: Compare results from PyTorch with a manual backpropagation calculation
series: PyTorch
canonical_url: https://nestedsoftware.com/2019/08/15/pytorch-hello-world-37mo.156165.html
tags: python, pytorch, neuralnetworks, machinelearning
---

I recently started working with [PyTorch](https://pytorch.org/), a Python framework for neural networks and machine learning. Since machine learning involves processing large amounts of data, sometimes it can be hard to understand the results that one gets back from the network. Before getting into anything more complicated, let's replicate a really basic backpropagation as a sanity check. To run the code in this article, you'll need to install [NumPy](https://www.numpy.org/) and [PyTorch](https://pytorch.org/get-started). 

In [neural networks primer]({% link _posts/2019-05-05-neural-networks-primer-374i.105712.md %}), we saw how to manually calculate the forward and back propagation for a tiny network consisting of one input neuron, one hidden neuron, and one output neuron:

![Sample calculation](/assets/images/2019-08-15-pytorch-hello-world-37mo.156165/7xbmlv7qpot4zvrioaxf.png)

We ran an input of _0.8_ through the network, then backpropagated using _1_ as the target value, with a learning rate of _0.1_. We used sigmoid as the activation function and the quadratic cost function to compare the actual output from the network with the desired output. 

The code below uses PyTorch to do the same thing:

```python
import torch
import torch.nn as nn
import torch.optim as optim


class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.hidden_layer = nn.Linear(1, 1)
        self.hidden_layer.weight = torch.nn.Parameter(torch.tensor([[1.58]]))
        self.hidden_layer.bias = torch.nn.Parameter(torch.tensor([-0.14]))

        self.output_layer = nn.Linear(1, 1)
        self.output_layer.weight = torch.nn.Parameter(torch.tensor([[2.45]]))
        self.output_layer.bias = torch.nn.Parameter(torch.tensor([-0.11]))

    def forward(self, x):
        x = torch.sigmoid(self.hidden_layer(x))
        x = torch.sigmoid(self.output_layer(x))
        return x


net = Net()
print(f"network topology: {net}")

print(f"w_l1 = {round(net.hidden_layer.weight.item(), 4)}")
print(f"b_l1 = {round(net.hidden_layer.bias.item(), 4)}")
print(f"w_l2 = {round(net.output_layer.weight.item(), 4)}")
print(f"b_l2 = {round(net.output_layer.bias.item(), 4)}")

# run input data forward through network
input_data = torch.tensor([0.8])
output = net(input_data)
print(f"a_l2 = {round(output.item(), 4)}")

# backpropagate gradient
target = torch.tensor([1.])
criterion = nn.MSELoss()
loss = criterion(output, target)
net.zero_grad()
loss.backward()

# update weights and biases
optimizer = optim.SGD(net.parameters(), lr=0.1)
optimizer.step()

print(f"updated_w_l1 = {round(net.hidden_layer.weight.item(), 4)}")
print(f"updated_b_l1 = {round(net.hidden_layer.bias.item(), 4)}")
print(f"updated_w_l2 = {round(net.output_layer.weight.item(), 4)}")
print(f"updated_b_l2 = {round(net.output_layer.bias.item(), 4)}")

output = net(input_data)
print(f"updated_a_l2 = {round(output.item(), 4)}")
```

Some notes on this code:

* `nn.Linear` is used for fully connected, or dense, layers. For this simple case, we have a single input and a single output for each layer. 
* The `forward` method is called when we pass the input into the network with `output = net(input_data)`. 
* By default, PyTorch sets up random weights and biases. However, here we initialize them directly since we want the results to match our manual calculation (shown later in the article).
* In PyTorch, `tensor` is analogous to `array` in numpy. 
* `criterion = nn.MSELoss()` sets up the quadratic cost function - though it's called the mean squared error loss function in PyTorch. 
* `loss = criterion(output, target)` calculates the cost, also known as the loss. 
* Next we use `net.zero_grad()` to reset the gradient to zero (otherwise the backpropagation is cumulative). It isn't strictly necessary here, but it's good to keep this in mind when running backpropagation in a loop.
* `loss.backward()` computes the gradient, i.e. the derivative of the cost with respect to all of the weights and biases. 
* Finally we use this gradient to update the weights and biases in the network using the `SGD` (stochastic gradient descent) optimizer, with a learning rate of _0.1_. 

The results are below:

```
C:\Dev\python\pytorch>python backprop_pytorch.py
network topology: Net(
  (hidden_layer): Linear(in_features=1, out_features=1, bias=True)
  (output_layer): Linear(in_features=1, out_features=1, bias=True)
)
w_l1 = 1.58
b_l1 = -0.14
w_l2 = 2.45
b_l2 = -0.11
a_l2 = 0.8506
updated_w_l1 = 1.5814
updated_b_l1 = -0.1383
updated_w_l2 = 2.4529
updated_b_l2 = -0.1062
updated_a_l2 = 0.8515
```
We print out the network topology as well as the weights, biases, and output, both before and after the backpropagation step. 

Below, let's replicate this calculation with plain Python. This calculation is almost the same as the one we saw in the neural networks primer. The only difference is that PyTorch's `MSELoss` function doesn't have the extra division by 2, so in the code below, I've adjusted `dc_da_l2 = 2 * (a_l2-1)` to match what PyTorch does:

```python
import numpy as np


def sigmoid(z_value):
    return 1.0/(1.0+np.exp(-z_value))


def z(w, a, b):
    return w * a + b


def sigmoid_prime(z_value):
    return sigmoid(z_value)*(1-sigmoid(z_value))


def dc_db(z_value, dc_da):
    return sigmoid_prime(z_value) * dc_da


def dc_dw(a_prev, dc_db_value):
    return a_prev * dc_db_value


def dc_da_prev(w, dc_db_value):
    return w * dc_db_value


a_l0 = 0.8
w_l1 = 1.58
b_l1 = -0.14
print(f"w_l1 = {round(w_l1, 4)}")
print(f"b_l1 = {round(b_l1, 4)}")

z_l1 = z(w_l1, a_l0, b_l1)
a_l1 = sigmoid(z_l1)

w_l2 = 2.45
b_l2 = -0.11
print(f"w_l2 = {round(w_l2, 4)}")
print(f"b_l2 = {round(b_l2, 4)}")

z_l2 = z(w_l2, a_l1, b_l2)
a_l2 = sigmoid(z_l2)
print(f"a_l2 = {round(a_l2, 4)}")

dc_da_l2 = 2 * (a_l2-1)
dc_db_l2 = dc_db(z_l2, dc_da_l2)
dc_dw_l2 = dc_dw(a_l1, dc_db_l2)
dc_da_l1 = dc_da_prev(w_l2, dc_db_l2)

step_size = 0.1
updated_b_l2 = b_l2 - dc_db_l2 * step_size
updated_w_l2 = w_l2 - dc_dw_l2 * step_size

dc_db_l1 = dc_db(z_l1, dc_da_l1)
dc_dw_l1 = dc_dw(a_l0, dc_db_l1)

updated_b_l1 = b_l1 - dc_db_l1 * step_size
updated_w_l1 = w_l1 - dc_dw_l1 * step_size

print(f"updated_w_l1 = {round(updated_w_l1, 4)}")
print(f"updated_b_l1 = {round(updated_b_l1, 4)}")

print(f"updated_w_l2 = {round(updated_w_l2, 4)}")
print(f"updated_b_l2 = {round(updated_b_l2, 4)}")

updated_z_l1 = z(updated_w_l1, a_l0, updated_b_l1)
updated_a_l1 = sigmoid(updated_z_l1)
updated_z_l2 = z(updated_w_l2, updated_a_l1, updated_b_l2)
updated_a_l2 = sigmoid(updated_z_l2)
print(f"updated_a_l2 = {round(updated_a_l2, 4)}")
```

Here are the results:

```
C:\Dev\python\pytorch>python backprop_manual_calculation.py
w_l1 = 1.58
b_l1 = -0.14
w_l2 = 2.45
b_l2 = -0.11
a_l2 = 0.8506
updated_w_l1 = 1.5814
updated_b_l1 = -0.1383
updated_w_l2 = 2.4529
updated_b_l2 = -0.1062
updated_a_l2 = 0.8515
```
We can see that the results match the ones from the PyTorch network! In the next article, we'll use PyTorch to recognize digits from the MNIST database. 

The code is available on github:

{% github nestedsoftware/pytorch %}

## Related

* [Neural Networks Primer]({% link _posts/2019-05-05-neural-networks-primer-374i.105712.md %})
