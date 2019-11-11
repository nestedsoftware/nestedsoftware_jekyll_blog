---
title: Coding Interview&#58; The Matchstick Game
published: true
description: Programming interview problem solving walkthrough 
cover_image: /assets/images/2019-03-05-coding-interview-the-matchstick-game-43a8.88358/tdwjejyra24um12zxevu.jpg
canonical_url: https://nestedsoftware.com/2019/03/05/coding-interview-the-matchstick-game-43a8.88358.html
tags: elm, problem solving, interview
---

In this article I'd like to do an interview-style problem-solving and coding exercise. I haven't actually encountered this problem in an interview - I ran across it as a kid on an old computer - but I do think it's a good candidate for an interview. It doesn't rely on sophisticated math or algorithms, so it's a good way to assess basic problem-solving and programming skills. The implementation will be in [elm](https://elm-lang.org/), a pure functional language/front-end web framework. I decided to use elm mainly because I hadn't tried it before, so this article was a good excuse to learn something new.

## The Rules

The rules of this game are very simple: The game starts with 21 matchsticks laid out in front of two players. The players take turns removing 1, 2, or 3 matchsticks at a time. The player who is forced to take the last matchstick loses.

## Simplify The Problem

Is there an optimal way to play this game? To figure this out, let's simplify the problem as much as possible: Let's say there is only 1 matchstick left and it's our turn. We have to take it, and therefore we lose.

However, if there are 2 matchsticks, we can take 1, and leave the last one behind for the other player to take. With 3 matchsticks, we can take two, which also leaves one left over. If there are 4 matchsticks, we can take 3, and the other player is again forced to take the last one. 

## The Pattern

We can see the emergence of an inductive pattern: With 1 matchstick, we lose. With 2, 3, and 4, we win. Now, with 5 we're in trouble again: No matter what we do, our opponent will be left with 2, 3, or 4 matches, and we already know that means they can win. With 6, 7, or 8 matches, we are again in a winning position. At 9 we're losing again, and so on.

We can translate this pattern into a bit of simple algebra: If there are m × 4 + 1 matchsticks, where m is an integer between 0 and 5, the current player is in a losing position. The goal of the game therefore becomes to try to get one's opponent into one of these losing positions - from there it becomes a one-way street. We can see that the player who starts the game is sadly doomed to lose! That is, unless the other player makes a mistake!

## Working toward Code

We know that the following values of `count` represent losing positions:

`count = m × 4 + 1`

`m` is an integer between 0 and 5, and `4` is one more than the maximum number of matchsticks a player can take.

Let's solve for m using integer division:

`m = (count - 1) ÷ 4`

The remainder of the integer division is:

`r = (count - 1) mod 4`


If the remainder is 0, we're in a losing position, so we can just take 1 matchstick: Either it's the last one, and the game is over, or we can extend the game, hoping our opponent will make a mistake. 

On the other hand, if the remainder is not 0, then we can win. How many matchsticks should we take in that case? Well, we want our opponent to get a remainder of 0 when it's their turn to perform this calculation. Therefore, all we need to do is remove the number of matchsticks corresponding to `r` - it's the difference between the current number of matchsticks and the next losing position.

In pseudocode, we can describe this as `if r is 0 take 1 else take r`.

## Unit Test

Let's write a unit test to make sure our calculation works out correctly:

```elm
test "matchsticksToTake gives correct values for 1 to 21" <|
    \_ ->
        let
            expectedMatchsticksToTake =
                [ ( 1, 1 ) -- lose
                , ( 2, 1 ) -- win
                , ( 3, 2 ) -- win
                , ( 4, 3 ) -- win
                , ( 5, 1 ) -- lose
                , ( 6, 1 ) -- win
                , ( 7, 2 ) -- win
                , ( 8, 3 ) -- win
                , ( 9, 1 ) -- lose
                , ( 10, 1 ) -- win
                , ( 11, 2 ) -- win
                , ( 12, 3 ) -- win
                , ( 13, 1 ) -- lose
                , ( 14, 1 ) -- win
                , ( 15, 2 ) -- win
                , ( 16, 3 ) -- win
                , ( 17, 1 ) -- lose
                , ( 18, 1 ) -- win
                , ( 19, 2 ) -- win
                , ( 20, 3 ) -- win
                , ( 21, 1 ) -- lose
                ]

            matchsticks =
                List.range 1 21

            actualMatchsticksToTake =
                List.map
                    (\count -> matchsticksToTake count)
                    matchsticks
        in
        Expect.equal
            expectedMatchsticksToTake
            actualMatchsticksToTake

```

> `matchsticksToTake` also returns the matchstick count to make testing a bit easier.

## Business Logic

We've already worked out the basic logic, so let's show the actual implementation:

```elm
matchsticksToTake : Int -> ( Int, Int )
matchsticksToTake count =
    let
        remainder =
            remainderBy 4 (count - 1)

        take =
            if remainder == 0 then
                1

            else
                remainder
    in
    ( count, take )
```

That's it! Our test passes and the core logic of the game is done!

## User Interface and Gameplay

An interesting aspect of programming is that the business logic can be a relatively small part of the total codebase. In conducting an interview, I think I'd probably just ask for a simple command-line implementation of this game. Even the small amount of code I've written in elm to make the game work may be too much for an interview coding session. However, if you're interested, follow along and I'll briefly summarize that part as well.

We want to make the simplest user interface possible to demonstrate the functionality. Of course we need to display the current number of matchsticks. We also need to know who's turn it is. I decided to show how many matchsticks were taken on the previous turn as well. Lastly we need some buttons to let the player choose the number of matchsticks they want to take. Here's the corresponding elm code: 

```elm
view : Model -> Html Msg
view model =
    div []
        [ h1
            []
            [ playerTurnLabel model ]
        , h1 [] [ text (String.fromInt model.matchsticks) ]
        , button [ onClick (Take 1), disabled (disable model) ]
            [ text "take 1" ]
        , button [ onClick (Take 2), disabled (disable model) ]
            [ text "take 2" ]
        , button [ onClick (Take 3), disabled (disable model) ]
            [ text "take 3" ]
        , p [] [ text <| lastMoveString model.lastSelection ]
        ]
```
We can see that we just need a very simple model to keep track of the game state for this user interface:

```elm
type alias Model =
    { currentPlayer : Player
    , matchsticks : Int
    , lastSelection : Selection
    }


type Player
    = ComputerPlayer
    | HumanPlayer


type Selection
    = Selected Player Int
    | NoneSelected
```

We're keeping track of the current player, the current number of matchsticks, and the previous player's selection.

On each turn of the game, elm will call our `update` callback with a message. The message will contain the number of matchsticks the current player wishes to take:

```elm
type Msg
    = ComputerTake Int
    | Take Int
    | DoNothing
```

Either the computer (`ComputerTake`) or the human player (`Take`) wants to play a turn. If the message is `DoNothing`, that just means we return the current model without making any changes.

When the application starts, the elm runtime calls the `init` function:

```elm
init : () -> ( Model, Cmd Msg )
init _ =
    -- let the computer start the game
    wrapNextMsgWithCmd
        ( Model ComputerPlayer 21 NoneSelected, computerTakesNextTurn 21 )
```

We want the computer to take the first turn for the human player to have a chance to win, so we initialize `currentPlayer` to `ComputerPlayer`. We set up `21` matchsticks, and the `lastSelection` is `NoneSelected` since there was no previous turn. 

`computerTakesNextTurn 21` returns a message that we want to send to update representing the computer's turn. The trick here is that we want to delay this message a bit so that we don't update the screen immediately after each human player's turn. To do that, we use a `Cmd`. Normally commands are used to perform side-effects, like sending an http request. Here we're using a command to delay the computer's turn. We're basically saying "please issue this command, and then send the following message to `update`." 

For testing purposes, it seemed easier to have `computerTakesNextTurn` produce just a simple `Msg`. The purpose of `wrapNextMsgWithCmd` is to wrap the desired command around that message:

```elm
wrapNextMsgWithCmd : ( Model, Msg ) -> ( Model, Cmd Msg )
wrapNextMsgWithCmd ( nextModel, nextMsg ) =
    ( nextModel, wrapWithCmd nextMsg )


wrapWithCmd : Msg -> Cmd Msg
wrapWithCmd nextMsg =
    case nextMsg of
        DoNothing ->
            Cmd.none

        Take _ ->
            Cmd.none

        ComputerTake _ ->
            Cmd.batch
                [ Task.perform
                    (\_ -> nextMsg)
                    (Process.sleep 3000)
                ]
``` 

Here we see that if we want the next message sent to `update` to be a computer turn (`ComputerTake`), then we produce a `Cmd` that includes this message. The `Cmd` will run the `Process.sleep` task for 3 seconds, then it will call update with `nextMsg`. 

`updateWithoutCmd` handles the basic game play:

```elm
updateWithoutCmd : Msg -> Model -> ( Model, Msg )
updateWithoutCmd msg model =
    case msg of
        Take selectedMatchsticks ->
            humanPlayerTakesTurn model selectedMatchsticks

        ComputerTake selectedMatchsticks ->
            computerPlayerTakesTurn model selectedMatchsticks

        DoNothing ->
            ( model, DoNothing )


humanPlayerTakesTurn : Model -> Int -> ( Model, Msg )
humanPlayerTakesTurn model selectedMatchsticks =
    case model.currentPlayer of
        HumanPlayer ->
            tryToPlayTurn
                model
                selectedMatchsticks
                (computerPlaysNextOrEndOfGame
                    model.matchsticks
                    selectedMatchsticks
                )

        ComputerPlayer ->
            rejectPlayerTurn model


computerPlayerTakesTurn : Model -> Int -> ( Model, Msg )
computerPlayerTakesTurn model selectedMatchsticks =
    case model.currentPlayer of
        ComputerPlayer ->
            tryToPlayTurn model selectedMatchsticks DoNothing

        HumanPlayer ->
            rejectPlayerTurn model
```

This code makes sure that if a player tries to take matchsticks, it's actually their turn. It also checks that the number of matchsticks is valid. `rejectPlayerTurn` may not really be needed, since we grey out the input buttons, but as someone who's written a lot of server-side code, old habits die hard!

We can see that after a human player takes a turn, we generate the message for the computer player to play next with `computerPlaysNextOrEndOfGame`: 

```elm
computerPlaysNextOrEndOfGame : Int -> Int -> Msg
computerPlaysNextOrEndOfGame matchsticks selectedMatchsticks =
    if gameOver (matchsticks - selectedMatchsticks) then
        DoNothing

    else
        computerTakesNextTurn <|
            takeMatchsticks matchsticks selectedMatchsticks

computerTakesNextTurn : Int -> Msg
computerTakesNextTurn matchsticks =
    ComputerTake <| Tuple.second <| matchsticksToTake matchsticks
```

We can see that if the game is not over after the human player's current turn, then we generate the appropriate `ComputerTake` message. This message will include the `matchsticksToTake` for the computer player based on the number of matchsticks left after the current player's selection.

## Elm Architecture

The basic [elm architecture](https://guide.elm-lang.org/architecture/) is a fairly simple cycle: When the user interacts with the UI, this triggers the appropriate message to be sent to the `update` function. `update` returns a new model with changes based on the message it received. The elm runtime updates its internal state with this new model, and uses it to refresh the view. 

`update` also returns a `Cmd` which can be used ask elm to perform side-effects. elm is a pure language, so none of the functions in elm directly perform I/O. They just return `Cmd` objects with instructions. The `elm` runtime uses these commands to perform the actual I/O, but it's done as a separate step.

In addition to commands, elm also supports [subscriptions](https://guide.elm-lang.org/effects/time.html), which can be used to handle periodic updates, but we aren't using subscriptions in this example.

## Demo

You can view a [demo](https://codepen.io/nestedsoftware/pen/LaNqRP) of this example at codepen: 

{% codepen https://codepen.io/nestedsoftware/pen/LaNqRP %}

## Source Code

All of the source code is available at github:

{% github nestedsoftware/matchstick-game %}