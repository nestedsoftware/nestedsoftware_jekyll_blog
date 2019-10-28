---
title: AlphaGo&#58; Observations about Machine Intelligence
published: true
description: AlphaGo and observations about machine intelligence
cover_image: /assets/images/2018-05-06-alphago-observations-about-machine-intelligence-4c62.29677/xr297vydxhsb271pmiii.jpg
canonical_url: https://nestedsoftware.github.io/2018/05/06/alphago-observations-about-machine-intelligence-4c62.29677.html
tags: ai, deeplearning, alphago, weiqi
---

## DeepMind and AlphaGo 

I enjoy playing the game of [go](https://en.wikipedia.org/wiki/Go_(game)) (not to be confused with the programming language). It's also known as baduk in Korea and weiqi in China. In the last several years, [DeepMind](https://deepmind.com/) has made a profound revolution in the world of go and AI with [AlphaGo](https://deepmind.com/research/alphago/). Prior to AlphaGo, the best go AIs, based on MCTS or [Monte Carlo tree search](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search), were relatively weak. A strong amateur player could beat them, and they stood no chance against professional players. 

DeepMind's AlphaGo, using [deep learning](https://en.wikipedia.org/wiki/Deep_learning), changed all that.  In January 2016, DeepMind released the news that AlphaGo had trounced the retired Chinese professional player, Fan Hui, in a series of even games. The go community had thought such a milestone was still about 10 years away at the time. 

Later, in the Spring of 2016, AlphaGo defeated one of the world's best active players, Lee Sedol, 4-1 in a 5 game series. In May of 2017, an even stronger version of AlphaGo beat the world #1 player Ke Jie 3-0 in a 3 game series. A similar version, playing several months earlier under the moniker of Master, had defeated all of the world's top professionals 60-0 in games that were played online with fast time controls.

## AlphaGo Zero

The most interesting development perhaps came afterward though. These earlier versions of AlphaGo used neural networks to learn how to play go, but their ideas of what represented good moves were influenced by human games that were used to bootstrap the network's training. 

AlphaGo Zero, described in a Nature paper in the Fall of 2017, learned how to play go entirely on its own without using any human games, just by playing against itself. It started off with random moves and quickly became superhuman (with an ELO of about 4500) after only 3 days of training. Afterward, DeepMind trained it from scratch again, this time for 40 days, producing a AI with an estimated ELO of over 5000. For comparison, the top human players have an ELO of about [3600](https://www.goratings.org/en/). 

Also, earlier versions of AlphaGo did have several heuristics coded into the AI. For example, there is a concept known as a [ladder](https://en.wikipedia.org/wiki/Ladder_(Go)) in go. Reading out ladders was hand-coded into earlier versions. All such heuristics were removed from the Zero version, so it had to learn everything about go besides the rules entirely by itself.

>A ladder is a situation where you can chase a group diagonally across the board. If there is a friendly piece (known as a stone) in the right spot on the other side of the board, then the group can't be captured. If there isn't one, then it can. This is something that beginner players learn about almost right away after learning the rules of go, but it turns out it's not easy for the AI to learn this concept on its own.  

AlphaGo Zero exceeded the capabilities of all previous versions of AlphaGo after 40 days of training. It is now widely regarded to be the strongest go AI in the world, significantly stronger than any human player. 

This was a huge achievement in AI. While brute-force computation combined with human-tuned heuristics were sufficient for chess AIs to become unbeatable, go's high branching factor and whole-board strategic framework made it impossible to create a really strong AI using rules or strategies pre-defined by human beings. 

The pattern recognition of deep neural networks and the immense parallelism afforded by big data to train the network were both needed to finally crack the problem.

>While the resources needed to train the neural network were enormous (thousands of years worth of computing time for a single PC), once trained, far fewer computations were needed to actually play. From DeepMind's original paper: _During the match against Fan Hui, AlphaGo evaluated thousands of times fewer positions than Deep Blue did in its chess match against Kasparov; compensating by selecting those positions more intelligently_

## Human vs. Machine Learning Styles

DeepMind's paper about AlphaGo Zero made mention of something interesting: Ladders, which human beginners learn about when they first start to play, are something that AlphaGo Zero only digested much later in its self-played games. It's unclear when this actually happened. Here's what DeepMind's paper has to say about it: _Surprisingly, shicho (“ladder” capture sequences that may span the whole board) -- one of the first elements of Go knowledge learned by humans – were only understood by AlphaGo Zero much later in training_

It's a bit maddening that the paper doesn't say just how long it took Zero to figure out ladders, but let's assume it was about half-way through its initial training run of 3 days. If that's the case, Zero's ELO would already have been in the neighbourhood of 3000. That would place it among the top 500 or so professional players in the world.

This kind of phenomenon, where the AI's overall performance is very high, but it has blind spots for things that would be obvious to a human being, is important. If we're developing life-critical AI applications, we may think our AI has achieved exceptional performance, but it could still be vulnerable to occasionally making fairly trivial mistakes. The way that AI learns, at least for the time being, is very different from the way human cognition works.

>DeepMind retired AlphaGo soon after publishing their paper about Zero, so we don't know what other weaknesses might still be found as edge cases. However, there are several projects currently working on implementing the Zero architecture. It may take a bit longer, but eventually we should be able to study an AI with the same strength as AlphaGo Zero in more detail.

## Importance of Intuition and Experience

Another thing that struck me in DeepMind's paper about Zero is the importance of intuition and pattern recognition.  In DeepMind's paper, they show that a version of Zero that used only the neural network and did not try to read out any variations at all in the game still had an ELO of about 3000! That means, on average, it was able to play go at a professional level with pure pattern recognition! 

As we age, our ability to calculate rapidly and precisely declines, but this shows us the immense power of experience. Zero can play professional-level go, far beyond the level of almost any amateur player, and better than many professional players who trained full time starting at about age 8, without reading out any sequences at all. It just uses its equivalent of intuition to decide where the most important-looking place to play is. 

To me that's really astounding. I believe it has a lot to say about the importance of wisdom and experience for us human beings also.

## The Mind of a Novice

One last observation I'd like to share is about the difference in strength between Zero, which did not use any human games for its training, and Master, which had the same basic design but was trained with human games. In the end, Zero continued to improve significantly after Master's improvement seemed to level off (slightly below 5000 ELO). This suggests that the human games inhibited Master from exploring some valuable ideas. 

Indeed, Zero has revolutionized our ideas about how to play go. Many ways of playing that would have been immediately shut down by human professionals in the past are now being seen in a new light. As human beings, we too have to remain open to new ideas, and to try to push ourselves to explore more deeply, even when something may seem obviously foolish at first.

Zero has proved that the accepted wisdom of even the top experts in a given field can and should be questioned. We should always approach any subject with an open, curious mind, even if it challenges our preconceived notions. 

Also, if we use data produced by human experts when applying AI to other problems, it's worth keeping this kind of limitation in mind.  

## Conclusion and Caution

Before concluding this article, I think it's important to note that while DeepMind's achievement with AlphaGo is amazing, go remains a much more tractable problem than the open-ended problems of the real world. Go, like chess, is a [zero-sum game](https://en.wikipedia.org/wiki/Zero-sum_game) played on a finite board: There's always a winner and a loser at the end of a game. Go, like chess, is also a game of [perfect information](https://en.wikipedia.org/wiki/Perfect_information): Both players have access to the same board position and there is nothing hidden or random (like there is in poker for example). 

In the real world, totally unpredictable things can happen. Taking self-driving cars as an example, a pedestrian or another car can get in the way without warning. A sudden weather event could disrupt sensors. Construction crews may block off a section of road. It's very hard to anticipate all of the things that can happen and what an AI should do in response. 

There are also legal and ethical questions: If a car's AI has to swerve into some pedestrians, potentially injuring or killing them, to save the driver, should it do so? And if it does, can the manufacturer get sued? I think it would be very difficult to sue a human driver in such a circumstance, but the AI's behaviour is mediated by software and may be subject to different legal standards. 

Of course there is also always the potential problem of hacking.

I guess the bottom line is just that we have to be aware of how complicated the real world is and not to get too easily seduced by the achievements of AI in much more controlled settings (however impressive those achievements may be).

## Links

If you're interested in AlphaGo, consider checking out:

* [Mastering the Game of Go with Deep Neural Networks](https://storage.googleapis.com/deepmind-media/alphago/AlphaGoNaturePaper.pdf)
* [Mastering the Game of Go without Human Knowledge](https://deepmind.com/documents/119/agz_unformatted_nature.pdf)
* [Mastering Chess and Shogi by Self-Play with a
General Reinforcement Learning Algorithm](https://arxiv.org/abs/1712.01815)
* [AlphaGo Documentary](https://www.alphagomovie.com/)

Some 3rd-party implementations of DeepMind's AlphaGo Zero architecture:

* [Leela Zero](http://zero.sjeng.org/)
* [Facebook Elf OpenGo](https://research.fb.com/facebook-open-sources-elf-opengo/)
* [Minigo](https://github.com/tensorflow/minigo)

If you're interested in go more broadly:

* [Learn Go Online](https://online-go.com/learn-to-play-go)
* [Learn to Play Go](http://www.goodmovepress.com/), by Janice Kim
* [The Surrounding Game Movie](https://www.surroundinggamemovie.com/)
