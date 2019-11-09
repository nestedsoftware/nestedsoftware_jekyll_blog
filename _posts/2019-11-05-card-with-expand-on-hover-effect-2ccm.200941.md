---
title: Card with expand-on-hover effect
published: true
description: A demo of a selectable card with a cool expand-on-hover effect
cover_image: /assets/images/2019-11-05-card-with-expand-on-hover-effect-2ccm.200941/obbj6mlbljvhgl7ptoqf.jpg
canonical_url: https://nestedsoftware.com/2019/11/05/card-with-expand-on-hover-effect-2ccm.200941.html
tags: css, html, showdev
---

I recently came across a cool effect on a blog (I believe the original design came from the [Ghost](https://ghost.org/blog/) platform). When you hover over a card that links to an article, there's a transition that expands the card slightly - it goes back to its original size when you move the mouse away from it. 

I tend to appreciate simple, minimalist designs that don't overwhelm the user. I avoid in-your-face effects, transitions, and animations. Here however, the effect is subtle, yet I find that it adds a nice touch of sophistication to the design. 

In addition to the hover effect, I liked this card design, so I reverse-engineered it from scratch, using flexbox for layout. 

Below is the result of my efforts in codepen:

{% codepen https://codepen.io/nestedsoftware/pen/eYYVbNB %}

## Hover Effect

The hover effect is achieved with the following CSS:

```css
.fancy_card:hover {
  transform: translate3D(0,-1px,0) scale(1.03);
}
```

I got this CSS from the original site. I think it's quite clever: Not only do we expand the card slightly, but we also slide it upward a little bit at the same time. 

> This effect works smoothly in current versions of Chrome and Firefox, but it looks choppy in Edge.

## Box Shadow

I also got the following parameters from the original site:

```css
.fancy_card {
  box-shadow: 8px 14px 38px rgba(39,44,49,.06), 1px 3px 8px rgba(39,44,49,.03);
  transition: all .5s ease; /* back to normal */
}

.fancy_card:hover {
  box-shadow: 8px 28px 50px rgba(39,44,49,.07), 1px 6px 12px rgba(39,44,49,.04);
  transition: all .4s ease; /* zoom in */
}
```

I like the application of two box shadows (separated by commas), and how the box shadow expands when hovering over a card. Note also the slightly different timing for the forward and back transitions. I think these kinds of subtle cues aren't noticeable at a conscious level, but they contribute to an overall sense of quality when using a well-designed site.

## Centering

Below are a few more notes on the CSS design. I like how flexbox makes centering simple, both horizontally and vertically. The CSS below centers the card in the window:

```css
.container {
  display: flex;
  min-height: 100vh; /* expand height to center contents */
  height: 100vh;
  justify-content: center; /* center horizontally */
  align-items: center; /* center vertically*/
}
```

The following CSS vertically aligns the user's profile image and the reading duration text in the footer of the card:

```css
.card_footer {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  align-items: center; /* vertically align content */
}
```

## Header Image

I found that my header image was expanding beyond the boundaries of its container and hiding the rounded corners. This can be fixed by applying `overflow: hidden` to its parent:

```css
.fancy_card {
  overflow: hidden; /* otherwise header image won't respect rounded corners */
}
```

I also discovered that the header image got stretched out vertically and did not respect its aspect ratio. With a bit of searching, I found a solution that seems to work: 

```css
.card_image {
  width: 100%; /* forces image to maintain its aspect ratio; otherwise image stretches vertically */
}
```
Surprisingly, this change alone seems to solve the problem (at least for modern browsers). 

The complete HTML/CSS is available on [CodePen](https://codepen.io/nestedsoftware/pen/eYYVbNB), so feel free to take a look if you're interested.
