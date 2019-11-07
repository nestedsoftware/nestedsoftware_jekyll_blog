---
title: I can has web site?
published: true
description: Creating my professional landing page including a copy of my dev.to blog
cover_image: /assets/images/2019-11-04-i-can-has-web-site-4loc.197474/gnogt6p2lyzcp9xpl3a9.jpg
tags: python, jekyll, showdev
---

After thinking about doing it for a while, I finally went ahead and created a [landing page](https://nestedsoftware.com) for myself, along with a self-hosted copy of my DEV.to [blog](https://dev.to/nestedsoftware). 

There are a number of options for doing this. Recently [Stackbit](https://www.stackbit.com/) has created a service that allows DEV.to users to automatically generate a copy of their blog: 

* [https://dev.to/devteam/you-can-now-generate-self-hostable-static-blogs-right-from-your-dev-content-via-stackbit-7a5](https://dev.to/devteam/you-can-now-generate-self-hostable-static-blogs-right-from-your-dev-content-via-stackbit-7a5)

I tried this service out, and it's pretty cool! You can generate a blog hosted on [Netlify](https://www.netlify.com/) with just a few clicks. 

While I did model my list of articles on one of Stackbit's themes, ultimately I decided to set up my own site. With generated sites, the CSS they use for layout can get a bit messy, which makes changing it more difficult. I ended up writing the CSS for my site from scratch. Also, the idea of creating something which didn't have dependencies on another service appealed to me. 

## Python Scripts

The first step was to download the contents of my DEV.to blog. To this end, I wrote a few Python scripts: `download_articles.py` uses DEV.to's [REST api](https://docs.dev.to/api/) to download the markdown for my published articles; `download_images.py` then downloads all of the images used in these articles; `copy_and_transform.py` creates a copy of the original content, using regular expressions to apply some transformations to the markdown. There's a master script, `main.py` which runs all of the above scripts. If you're interested in taking a look, you can find a copy of this code on GitHub:

* [https://github.com/nestedsoftware/markdown_manager](https://github.com/nestedsoftware/markdown_manager)

I wrote this code for my own purposes, so I can't guarantee that it will work for everyone else. I did run the scripts against @ben's posts and confirmed that they don't crash.

## Jekyll Static Site Generator

Next, I set up [Jekyll](https://jekyllrb.com/) to generate the HTML from these markdown files. I considered other generators like [Hugo](https://gohugo.io/) or [Gatsby](https://www.gatsbyjs.org/), but since DEV.to and Jekyll both use liquid tags and have similar formatting for front matter, Jekyll seemed like the most natural choice. 

I set up the Python scripts to produce a Jekyll-compatible directory structure, with articles going into the `_posts` folder, and images going into `assets/images`. The output from the scripts is then copied to the corresponding folders in the Jekyll project:

* [https://github.com/nestedsoftware/nestedsoftware_jekyll_blog](https://github.com/nestedsoftware/nestedsoftware_jekyll_blog)

Jekyll has been quite helpful for several things: I'm using DEV.to's support for a series of articles in a few places, and I found a bit of Jekyll [template code](https://github.com/realjenius/site-samples/blob/master/2012-11-03-jekyll-series-list/series.html) to handle this. I am also currently using the [jekyll-gist](https://github.com/jekyll/jekyll-gist) and [jekyll-codepen](https://github.com/rmcfadzean/jekyll-codepen) plugins. 

Syntax highlighting has probably been the most useful aspect of using Jekyll. I simply downloaded the appropriate [CSS theme](https://github.com/jwarby/jekyll-pygments-themes) for monokai, which tends to be my go-to theme, and voilà, I had a nice-looking display for code examples. 

## Design

One thing I found to be important was to design the appearance and layout separately from processing the content. I saved a couple of articles to a separate folder, and used that to create the CSS and HTML for the main components of my site: The landing page, the list of articles, and each individual article. This allowed me to focus on getting things to look the way I wanted them to. Once I felt this part was ready, I incorporated it into the Jekyll project.

## Comments

Supporting comments seems to be a rather hairy area. I found a neat little project called [utterances](https://utteranc.es/) which I've incorporated into my article template. Reader comments are posted as issues to a dedicated GitHub project - [blog_comments](https://github.com/nestedsoftware/blog_comments) in my case. It does require commenters to have a [GitHub](https://github.com/) account, but I like the simplicity and transparency of this solution. 

## Results

For the time being, I've deployed my small site to GitHub pages:

* [https://nestedsoftware.com](https://nestedsoftware.com) 

I used [Google Domains](https://domains.google) for the custom domain registration. Even though I'm not a designer, I'm pretty happy with the results, and it feels good to have a self-hosted version of my blog, as well as a central spot for my online presence. 

Writing some of these articles has been a lot of work, and it's been gnawing at the back of my mind that if something catastrophic were to happen to DEV.to, I would lose a huge amount of work! I know, realistically, it's not going to happen, but it still gives me some peace of mind knowing that I've got a back up. 

As a matter of principle, it's probably also worthwhile to host one's own blog. If you decide to do this, don't forget to update the `canonical_url` in the DEV.to front matter to point to your version of the same article. This applies for any other places where you may host copies of the same articles (see [canonical link element](https://en.wikipedia.org/wiki/Canonical_link_element) for reference).
