---
title: Tic-Tac-Toe with MCTS
published: true
cover_image: /assets/images/2019-08-07-tic-tac-toe-with-mcts-2h5k.152104/4538s35s9scpgpuqb2wx.jpg
description: Simple implementation of MCTS for tic-tac-toe in Python
series: Tic-Tac-Toe
canonical_url: https://nestedsoftware.com/2019/08/07/tic-tac-toe-with-mcts-2h5k.152104.html
tags: python, tictactoe, mcts, uct
---

So far in this series, we've implemented tic-tac-toe with [minimax]({% link _posts/2019-06-15-tic-tac-toe-with-the-minimax-algorithm-5988.123625.md %}) and [tabular Q-learning]({% link _posts/2019-07-25-tic-tac-toe-with-tabular-q-learning-1kdn.139811.md %}). In this article we'll use another common technique, [MCTS](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search), or Monte Carlo tree search. 

[Monte Carlo simulations](https://en.wikipedia.org/wiki/Monte_Carlo_method) are used in many different areas of computing.  Monte Carlo is a [_heuristic_](https://en.wikipedia.org/wiki/Heuristic_(computer_science)). With a heuristic, we are not guaranteed precisely the correct or the best answer, but we can get an approximation that can often be good enough. Some problems that can't be solved analytically, or (in a reasonable amount of time) by exhausting all possibilities, become tractable if we run a bunch of simulations instead.  

With MCTS, the simulations we perform are called _playouts_. A playout is a simulation of a single game, often from beginning to end, but sometimes from a given starting point to a given end point. When we get the result of the game, we update the statistics for each game position, or _node_, that was visited during that playout. The idea is to run a large enough number of playouts to statistically assess the value of taking a given action from a given state. The diagram below shows a part of a single playout for tic-tac-toe:

![mcts playout](/assets/images/2019-08-07-tic-tac-toe-with-mcts-2h5k.152104/6dpz3fabybointn48xte.png)

In the diagram, we choose a move for each position until we reach the end of the game (we'll look at how to make this choice in the next section). In this case, _X_ wins, so we increment the win count and the number of visits for the final position. We increment the win count because _X_'s previous move that led to this position produced a win for _X_. For the previous position, we increment the loss count instead of the win count. That's because _O_'s move that led to that position ended up as a win for _X_: For that particular playout, it was a losing move. We go through the move history of the playout, alternating between updating the win and loss count (and the visit count) for each node that was visited. If _O_ wins, then we do the same thing, incrementing the win count for the final position, and then we alternate as before. If it's a draw, then we just increment the draw count and visit count for each position in the playout. There is a similarity to the way Minimax works here, and in fact, MCTS approximates minimax as we increase the number of simulations.

## Selection and Upper Confidence Bound

How do we select the moves for a given playout? It turns out there are a lot of possible approaches. A simple way to produce a playout would be to choose random moves each time until the end-of-game state, then to update the statistics as described above. 

In this article, I've chosen to implement [UCB-1](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search#Monte_Carlo_Method) (upper confidence bound), a technique that has seen some significant success in machine learning in recent years. This technique of applying an upper confidence bound to MCTS is also sometimes referred to as [UCT](https://www.chessprogramming.org/UCT) (upper confidence trees). UCT is an interesting idea used to efficiently select moves during a playout. As with epsilon-greedy (discussed in the previous [article]({% link _posts/2019-07-25-tic-tac-toe-with-tabular-q-learning-1kdn.139811.md %})), the goal is to find a suitable balance between _exploration_ (trying a move just to see what happens) and _exploitation_ (visiting the node that already has a high value from previous simulations).

To calculate the upper confidence bound, we need the following information:

* N<sub>i</sub>: The number of visits to the parent node (the position from which we're selecting a move)
* n<sub>i</sub>: The number of visits to a given child node (the position resulting from choosing a move)
* w<sub>i</sub>: The number of wins for a given child node
* c is a constant that can be adjusted. The default value is the square root of 2, or _√2_.

Given a position to start from, we apply the following formula for the position resulting from each possible move, then we choose the move with the highest value:

![ucb1](/assets/images/2019-08-07-tic-tac-toe-with-mcts-2h5k.152104/eh886tke4wwtsywdd8xr.png)

The upper confidence bound has two terms. The first is the _winrate_ for a given node. For tic-tac-toe, I use the sum of wins and draws, since we know that a draw is the best possible result if neither player makes a mistake:

```python
class Node:
    # other code omitted...
    def value(self):
        if self.visits == 0:
            return 0

        success_percentage = (self.wins + self.draws) / self.visits
        return success_percentage
```

The second term is the _exploration term_. This term increases for a given node when it hasn't been visited very much relative to the number of visits to the parent node. In the numerator, we've got the natural log of the number of visits to the parent node. The denominator is the number of visits to the current child node. If we don't visit a given child node, then the increase in the number of visits to the parent node will gradually increase the exploration term over time. Given enough time, the exploration term will get high enough for that child node to be selected:

![ratio numerator](/assets/images/2019-08-07-tic-tac-toe-with-mcts-2h5k.152104/qj85q41542hacbmixfj7.png)

If we keep increasing the number of visits to the parent node without visiting a given child node, we can see that the overall exploration term above will gradually increase. However, because it is scaled by the natural log, this increase is slow relative to the number of visits.

Each time we do visit a child node, this increments the denominator, which entails a decrease in the exploration term:

![ratio denominator](/assets/images/2019-08-07-tic-tac-toe-with-mcts-2h5k.152104/x6i8btrl4sa55hchrl5l.png)

Since the denominator, unlike the numerator, is not scaled down, if selecting the child node doesn't increase the winrate, then it will decrease the value of exploring that choice quite rapidly. Overall, if exploring a node has not been promising in the past, it may take a long time before that node is selected again, but it will happen eventually, assuming we run enough playouts.

This approach to the problem of exploration vs exploitation was derived from [Hoeffding's inequality](https://en.wikipedia.org/wiki/Hoeffding%27s_inequality). For more details, see the paper [Using Confidence Bounds for Exploitation-Exploration Trade-offs](http://www.jmlr.org/papers/volume3/auer02a/auer02a.pdf), by Peter Auer.

## Implementation

My implementation of MCTS for tic-tac-toe reuses the `BoardCache` class from the previous articles in this series. This object stores symmetrical board positions as a single key. In order to be able to take advantage of this caching, I had to make some small adjustments to my MCTS implementation. In particular, several distinct positions can lead to the same child position, for instance:

![multiple parent nodes](/assets/images/2019-08-07-tic-tac-toe-with-mcts-2h5k.152104/o7yq2vhssxbhwmtounfv.png)

To handle this scenario, for a given child node, I keep track of all of its distinct parent nodes: I use the sum of the visits to the parent nodes to compute N<sub>i</sub>. Below is the core logic that the MCTS tic-tac-toe player uses to choose a move during a playout:

```python
def calculate_value(node_cache, parent_board, board):
    node = find_or_create_node(node_cache, board)
    node.add_parent_node(node_cache, parent_board)
    if node.visits == 0:
        return math.inf

    parent_node_visits = node.get_total_visits_for_parent_nodes()

    exploration_term = (math.sqrt(2.0)
                        * math.sqrt(math.log(parent_node_visits) / node.visits))

    value = node.value() + exploration_term

    return value
```

If a given child node has not been visited for a playout yet, we make its value infinite. That way, from a given parent node, we give the highest priority to checking every possible child node at least once. Otherwise, we add its current success percentage to the exploration term. Note that once we've performed our playouts, we select the actual move to play in a game by just using the highest success rate from the available options.

## Results

From what I understand, UCT should converge to produce the same results as minimax as the number of playouts increases. For tic-tac-toe, I found that pre-training with _4,000_ playouts produced results that were close to minimax, and in which the MCTS agent didn't lose any games (based on _1,000_ games played):

![results against various opponents](/assets/images/2019-08-07-tic-tac-toe-with-mcts-2h5k.152104/fzlxjjcv96epvpi2x96j.png)

In practice, I've found that MCTS is often used in an "online" mode. That is, instead of pre-training ahead of time, MCTS is implemented live. For example, the original version of AlphaGo used deep learning for move selection and position evaluation, but it also performed MCTS playouts before each move of a real (i.e. non-training) game. It used a combination of the neural network outputs and the results from playouts to decide which move to make. For tic-tac-toe, I tried doing online playouts after each move (without pre-training) and obtained good results (comparable to the table above) with _200_ simulations per move.

## Code

The code for this project is available on github ([mcts.py](https://github.com/nestedsoftware/tictac/blob/master/tictac/mcts.py)):

{% github nestedsoftware/tictac %}

## Related

* [Neural Networks Primer]({% link _posts/2019-05-05-neural-networks-primer-374i.105712.md %})
* [Convolutional Neural Networks: An Intuitive Primer]({% link _posts/2019-05-28-convolutional-neural-networks-an-intuitive-primer-k1k.114570.md %})

## References

* [MCTS](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search)
* [Monte-Carlo simulations](https://en.wikipedia.org/wiki/Monte_Carlo_method)
* [Hoeffding's inequality](https://en.wikipedia.org/wiki/Hoeffding%27s_inequality)
* [Using Confidence Bounds for Exploitation-Exploration Trade-offs](http://www.jmlr.org/papers/volume3/auer02a/auer02a.pdf), by Peter Auer
