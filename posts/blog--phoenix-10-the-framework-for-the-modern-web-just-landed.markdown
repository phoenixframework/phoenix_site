---
title: Phoenix 1.0 – the framework for the modern web just landed
author: Chris McCord
created: 2015-08-28
phoenix_version: v1.0.0
---


![](/assets/img/blog/1.0-ann/diff.png)

After a year and a half of work, 2500 commits, and 30 releases, Phoenix 1.0 is here! With 1.0 in place, Phoenix is set to take on the world whether you're building APIs, HTML5 applications, or network services for native devices. Written in Elixir, you get beautiful syntax, productive tooling and a fast runtime. Along the way, we've had many [success stories of companies using phoenix in production](https://www.youtube.com/watch?v=xT8vDHIvurs&feature=youtu.be), and two ElixirConf's where we showed off Phoenix's progress.

## Many Thanks

Before we jump into some of the great things Phoenix has to offer, we owe thanks to the people that helped make this possible.

### José Valim

Though he'll try to downplay his efforts, José paved the way for Phoenix with a level of contribution that is simply amazing. He not only wrote Elixir, but bootstrapped Phoenix with the [Plug](https://github.com/elixir-lang/plug) library, opened database access with [Ecto](https://github.com/elixir-lang/ecto), and contributed thousands of lines of code to Phoenix itself. Along the way, he crafted Elixir releases and helped build a community that has been such a pleasure to be a part of. Thank you!

### phoenix-core

The core team devoted many of their nights and weekends to get where we are today. Whether it's [Lance Halvorsen](https://twitter.com/lance_halvorsen) writing the lovely Phoenix guides, [Jason Stiebs](https://twitter.com/peregrine) helping flesh out the initial channels layer, [Eric Meadows-Jönsson](https://twitter.com/emjii) working on hex.pm and making sure we have graceful fallback for older browsers, or [Sonny Scroggin](https://twitter.com/scrogson) contributing in many areas while training newcomers, these people helped make Phoenix what it is today.


## The real-time web

From the beginning, Phoenix has been focused on taking on the real-time web. The goal was to make real-time communication just as trivial as writing a REST endpoint. We've realized that goal with channels. This 90 second clip of a collaborative editor should give you a sense of what's possible:

<iframe width="560" height="315" src="https://www.youtube.com/embed/GLa9gtvP13Y" frameborder="0" allowfullscreen></iframe>

Channels give you a multiplexed connection to the server for bidirectional communication. Phoenix also abstracts the transport layer, so you no longer have to be concerned with how the user has connected. Whether WebSocket, Long-polling, or a custom transport, your channel code remains the same. You write code against an abstracted "socket", and Phoenix takes care of the rest. Even on a cluster of machines, your messages are broadcasted across the nodes automatically. Phoenix's javascript client also provides an API that makes client/server communication beautifully simple. This is what it looks like:

![](/assets/img/blog/1.0-ann/channels.png)


## Beyond the browser

As a "web framework", Phoenix targets traditional browser applications, but the so-called "web" is evolving. And we need a framework to evolve with it. Phoenix transcends the browser by connecting not only browsers, but iPhones, Android handsets, and smart devices alike. [Justin Schneck](https://twitter.com/mobileoverlord), [Eoin Shanaghy](https://twitter.com/eoins), and [David Stump](https://twitter.com/davidstump) helped Phoenix realize this goal by writing channel clients for objC, Swift, C#, and Java. To appreciate what this enables, Justin demo'd a Phoenix chat application running on an Apple Watch, iPhone, and web browser all powered by native phoenix channel clients:

<iframe src="https://player.vimeo.com/video/136679715" width="640" height="400" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>


## Productivity in the short term and the long term

In addition to high connectivity, Phoenix gives you a comfortable feature set to get up and running quickly and be productive with your team. But, Software isn't just about the short-term. Elixir leverages tried and true patterns for long-term project success and maintainability. The Erlang runtime was designed for systems to run for many years, with minimal downtime. Using these patterns and the runtime innovations, you can deploy systems that self-heal, support hot-code uploading, and have capabilities known to support *millions* of connected users. Out of the box, Phoenix provides:

### Short-term productivity
- Project generation with `mix phoenix.new my_app`
- Live-reload in development. Make a change to any template, view, or asset and see the results immediately in the browser
- Postgres, MySQL, MSSQL, and MongoDB resources through [Ecto](https://github.com/elixir-lang/ecto) integration
- Resource generators, such as `mix phoenix.gen.html User users name:string age:integer` to bootstrap a project and learn the ins and outs of phoenix best practices
- A precompiled view layer with EEx templates for lightning fast response times, often measuring in *microseconds*
- Channels for realtime communication
- and more

### Long-term productivity
- The ability to run multiple phoenix applications side-by-side in the same OS process or break a bigger application into smaller chunks with umbrella apps: http://blog.plataformatec.com.br/2015/06/elixir-in-times-of-microservices/
- Erlang OTP tooling to get a live look into your running application and diagnose issues:

![](/assets/img/blog/1.0-ann/observer.png)


## What's Next?

We're just getting started with 1.0. With a strong and stable core in place, we'll be building Channel Presence features, internationalization, and more. Be sure to [register for ElixirConf]() in October to find out yet unannounced plans beyond Phoenix 1.1 and other neat things happening in the Elixir ecosystem. José Valim is also hosting a Phoenix webinar on Sept 4 to talk about Phoenix and answer viewer questions.

- [Phoenix webinar & Q/A with José Valim](http://pages.plataformatec.com.br/webinar-phoenix-framework-with-jose-valim), Sept 4
- [ElixirConf](http://elixirconf.com), October 1-3 Austin, TX


## Getting Started

So how can you join in on all this fun? The [Phoenix guides](http://www.phoenixframework.org) will take you through the basics and get you up and running quickly. If you're new to Elixir, here's a few resources to get up to speed before jumping into Phoenix:

- [elixir-lang.org getting started guides](http://elixir-lang.org/getting-started/introduction.html)
- [How I Start:  Elixir](https://howistart.org/posts/elixir/1)
- [Elixir Workshop](http://www.chrismccord.com/blog/2014/05/27/all-aboard-the-elixir-express/)


It has been an amazing ride, and we're just getting started. Let's show the world what Elixir and Phoenix can do.

–Chris
