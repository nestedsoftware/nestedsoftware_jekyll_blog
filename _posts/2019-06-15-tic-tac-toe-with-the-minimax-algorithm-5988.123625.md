---
title: Tic-Tac-Toe with the Minimax Algorithm
published: true
cover_image: /assets/images/2019-06-15-tic-tac-toe-with-the-minimax-algorithm-5988.123625/pkgy4v2fobn3iqdr4881.jpg
description: Simple implementation of the minimax algorithm for tic-tac-toe in Python
series: Tic-Tac-Toe
canonical_url: https://nestedsoftware.github.io/2019/06/15/tic-tac-toe-with-the-minimax-algorithm-5988.123625.html
tags: python, tic-tac-toe, minimax, algorithms
---

In this article, I'd like to show an implementation of a tic-tac-toe solver using the [minimax](https://en.wikipedia.org/wiki/Minimax) algorithm. Because it's such a simple game with relatively few states, I thought that tic-tac-toe would be a convenient case study for machine learning and AI experimentation. Here I've implemented a simple algorithm called minimax.

The basic idea behind minimax is that we want to know how to play when we assume our opponent will play the best moves possible. For example, let's say it's _X's_ turn and _X_ plays a particular move. What's the value of this move? Suppose that _O_ can respond in one of two ways: In the first case, _O_ wins on the next move. The other move by _O_ leads to a win by _X_ on the following move. Since _O_ can win, we consider the original move by _X_ a bad one - it leads to a loss. We ignore the fact that _X_ could win if _O_ makes a mistake. We'll define a value of _1_ for a win by _X_, _-1_ for a win by _O_, and _0_ for a draw. In the above scenario, since _O_ can win on the next move, the original move by _X_ is assigned a value of _-1_.

The minimax algorithm applies this strategy recursively from any given position - we explore the game from a given starting position until we reach all possible end-of-game states. We can represent this as a tree, with each level of the tree showing the possible board positions for a given player's turn. When we reach an end-of-game state, there's no choice to be made, so the value is the game result, that is _1_ if _X_ won, _-1_ if _O_ won, and _0_ if it was a draw. If it is _X's_ turn and it's not a final board state, we choose the _maximum_ of the values of the next possible moves from that position in the tree. This represents the best possible option for _X_. If it is _O_'s turn, then we choose the _minimum_ of these values, which is the best option for _O_. We keep propagating the position values upward toward the root position, alternating between maximum and minimum values as we go - which is of course where the minimax algorithm gets its name.

The diagram below shows an example of minimax applied to a board position:

![minimax](/assets/images/2019-06-15-tic-tac-toe-with-the-minimax-algorithm-5988.123625/eo3qr44bp1w96a92t8s2.png)

If the position is an end-of-game state, then the value of that position is the result of that game - that's the terminating condition for the recursive calls. Once we've reached the end-of-game positions, we can work our way back up toward the root position. For positions in the _max_ levels of the tree - where it is _X's_ turn - we choose the move with the maximum value from the possible continuations. For the positions in the _min_ levels of the tree - where it is _O's_ turn - we take the minimim value. In each case, we are looking for the best possible result for the current player's next move.  As we can see, the best _X_ can do in the diagram (as long as _O_ doesn't make a mistake) is to get a draw by playing in the top right-hand corner of the board.

> It's worth emphasizing that minimax works fine for a toy scenario like tic-tac-toe: There are few distinct game positions - _765_ if we take rotation and reflection symmetry into account. For more complex scenarios, including games like chess and go, minimax would, at the very least, have to be combined with other techniques. I haven't implemented it here, but [alpha-beta pruning](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning) can be used to reduce the number of positions that need to be visited. The overall idea is that if we know that exploring a subtree won't produce a better result than what we've already got, then we don't need to bother with it. There are additional heuristics as well. We can limit the depth of search, and once we hit that limit, we can use a heuristic to estimate the likely value of the position. This idea has been used extensively in chess engines like [Stockfish](https://hxim.github.io/Stockfish-Evaluation-Guide/). [MCTS](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search) is another technique that can be applied to simplify scenarios where minimax would result in too many combinations to keep track of. These days, for games like chess and go, deep learning has proven remarkably effective. In fact, it's far more effective than any other known technique.

Let's briefly look at the code needed to implement minimax. Note that this code is not written for maximum efficiency, just to illustrate the basic concepts. The project is available on [github](https://github.com/nestedsoftware/tictac). This code is from the [`minimax.py`](https://github.com/nestedsoftware/tictac/blob/master/tictac/minimax.py) file:

```python
def play_minimax_move(board):
    move_value_pairs = get_move_value_pairs(board)
    move = filter_best_move(board, move_value_pairs)

    return play_move(board, move)
```

`play_minimax_move` determines which move to play for a given board position. First it gets the values corresponding to each possible move, then plays the move with the maximum value if it's _X's_ turn, or the move with the minimum value if it's _O's_ turn.

`get_move_value_pairs` gets the value for each of the next moves from the current board position:

```python
def get_move_value_pairs(board):
    valid_move_indexes = get_valid_move_indexes(board)

    assert not_empty(valid_move_indexes), "never call with an end-position"

    move_value_pairs = [(m, get_position_value(play_move(board, m)))
                        for m in valid_move_indexes]

    return move_value_pairs
```

`get_position_value`, below, either obtains the value of the current position from a cache, or calculates it directly by exploring the game tree. Without caching, playing a single game takes about 1.5 minutes on my computer. Caching takes that down to about 0.3 seconds! A full search will encounter the same position over again many times. Caching allows us to speed this process up considerably: If we've seen a position before, we don't need to re-explore that part of the game tree.

```python
def get_position_value(board):
    cached_position_value, found = get_position_value_from_cache(board)
    if found:
        return cached_position_value

    position_value = calculate_position_value(board)

    put_position_value_in_cache(board, position_value)

    return position_value
```

`calculate_position_value` finds the value for a given board when it is not already in the cache. If we're at the end of a game, we return the game result as the value for the position. Otherwise, we recursively call back into `get_position_value` with each of the valid possible moves. Then we either get the minimum or the maximum of all of those values, depending on who's turn it is:

```python
def calculate_position_value(board):
    if is_gameover(board):
        return get_game_result(board)

    valid_move_indexes = get_valid_move_indexes(board)

    values = [get_position_value(play_move(board, m))
              for m in valid_move_indexes]

    min_or_max = choose_min_or_max_for_comparison(board)
    position_value = min_or_max(values)

    return position_value
```

We can see below that `choose_min_or_max_for_comparison` returns the `min` function if it is _O's_ turn and `max` if it is _X's_ turn:

```python
def choose_min_or_max_for_comparison(board):
    turn = get_turn(board)
    return min if turn == CELL_O else max
```

Going back to caching for a moment, the caching code also takes into account positions that are equivalent. That includes rotations as well as horizontal and vertical reflections. There are 4 equivalent positions under rotation: 0°, 90°, 180°, and 270°. There are also 4 reflections: Flipping the original position horizontally and vertically, and also rotating by 90° first, then flipping horizontally and vertically. Flipping the remaining rotations is redundant:  Flipping the 180° rotation will produce the same positions as flipping the original position; flipping the 270° rotation will produce the same positions as flipping the 90° rotation. Without taking into account rotation and reflection, a single game takes approximately 0.8 seconds on my computer, compared to the 0.3 seconds when caching is also enabled for rotations and reflections. `get_symmetrical_board_orientations` obtains all of the equivalent board positions so they can be looked up in the cache:

```python
def get_symmetrical_board_orientations(board_2d):
    orientations = [board_2d]

    current_board_2d = board_2d
    for i in range(3):
        current_board_2d = np.rot90(current_board_2d)
        orientations.append(current_board_2d)

    orientations.append(np.flipud(board_2d))
    orientations.append(np.fliplr(board_2d))

    orientations.append(np.flipud(np.rot90(board_2d)))
    orientations.append(np.fliplr(np.rot90(board_2d)))

    return orientations
```

If you're interested in having a closer look, the github repo with all of the code for this project is available at:

* [https://github.com/nestedsoftware/tictac](https://github.com/nestedsoftware/tictac)

Below are the winning percentages for the different combinations of minimax and random players, with 1000 games played for each combination:

![winning percentages](/assets/images/2019-06-15-tic-tac-toe-with-the-minimax-algorithm-5988.123625/7jme6nri5hpakxhhr5j7.png)

We can see that if both players play perfectly, only a draw is possible, but _X_ is more likely to win if both players play at random.

## Related

* [AlphaGo: Observations about Machine Intelligence]({% link _posts/2018-05-06-alphago-observations-about-machine-intelligence-4c62.29677.md %})
* [Neural Networks Primer]({% link _posts/2019-05-05-neural-networks-primer-374i.105712.md %})
* [Convolutional Neural Networks: An Intuitive Primer]({% link _posts/2019-05-28-convolutional-neural-networks-an-intuitive-primer-k1k.114570.md %})
