---
title: Phoenix 0.10.0 released with assets handling, generators, & more
author: Chris McCord
created: 2015-03-09
phoenix_version: v0.10.0
---

We released Phoenix 0.10.0 this weekend and we're really excited to
share the new features we've been working on. This release brings an
asset build system powered by [brunch](http://brunch.io), live-reloading of
css/js/eex templates, form builders, and new [Ecto](https://github.com/elixir-lang/ecto) integration with generators
that lets you get up and running quickly.

There's so much good stuff packed into this release, that it deserved
a screencast so you can see it in action:

<iframe width="560" height="315" src="https://www.youtube.com/embed/Nh5OQjb8G9E" frameborder="0" allowfullscreen></iframe>

## Live-Reload

Change any css, js, or EEx template, and watch the browser instantly
reload with your changes. The best part is that we don't need any browser plugin. Everything is powered by Phoenix channels and works regardless of your javascript tooling of choice. Try it out–you'll love it.


## Static Asset Handling

We've integrated Brunch for fast and simple asset
compilation that Just Works. When you start your `mix phoenix.server`
in development, a brunch process is run automatically alongside your
endpoint and your assets in `web/static/js` and `web/static/css` will
be compiled as the files change. Even better, with our new live-reload
feature, those recompiles get reloaded in the browser for a
streamlined development experience. We've also built Brunch
integration in a way that will let you wire up your own asset system,
such as Gulp, Grunt, Webpack, etc.

Out of the box, we support Sass and ES6 javascript compilation, but
it's very easy to extend your `brunch-config.js` with additional tools
to support your asset workflow.

## We've integrated Brunch for fast and simple asset
compilation that Just Works. When you start your `mix phoenix.server`
in development, a brunch process is run automatically alongside your
endpoint and your assets in `web/static/js` and `web/static/css` will
be compiled as the files change. Even better, with our new live-reload
feature, those recompiles get reloaded in the browser for a
streamlined development experience. We've also built Brunch
integration in a way that will let you wire up your own asset system,
such as Gulp, Grunt, Webpack, etc.

Out of the box, we support Sass and ES6 javascript compilation, but
it's very easy to extend your `brunch-config.js` with additional tools
to support your asset workflow.

This release brings two new protocols, `Phoenix.HTML.FormData` and
`Phoenix.Param` that makes it simple to integrate your model layer
with Phoenix's new form and link builders. As a default, but optional
dep, we now include Ecto integration through the
[phoenix_ecto](https://github.com/phoenixframework/phoenix_ecto)
project where you can see these two new protocols in action. Let's check it out:

```erb
<%= form_for @changeset, @action, fn f -> %>
  <%= if @changeset.errors != [] do %>
    <p style="color: red">Oops, something went wrong!</p>
  <% end %>

  <p>
    <label>
      <span>Title:</span>
      <%= text_input f, :title %>
    </label>
  </p>

  <p>
    <label>
      <span>Rank:</span>
      <%= number_input f, :rank %>
    </label>
  </p>

  <p>
    <%= submit "Submit" %>
  </p>
<% end %>
```

`form_for` accepts an Ecto changeset here, but will support any data
structure that implements the `FormData` protocol. With form builders,
we inject the CSRF token for you automatically to verify requests and
you can enjoy the new form input helpers, ie `text_input`,
`number_input`.

In addition to forms, we now include a `link` function for building
anchors in your templates:

```erb
<%= for post <- @posts do %>
  <tr>
    <td><%= post.title %></td>
    <td><%= post.rank %></td>

    <td><%= link "Show", to: post_path(@conn, :show, post) %></td>
    <td><%= link "Edit", to: post_path(@conn, :edit, post) %></td>
    <td><%= link "Delete", to: post_path(@conn, :delete, post), method: :delete %></td>
  </tr>
<% end %>
```

Notice how we able to write `post_path(@conn, :show, post)` instead of
`post_path(@conn, :show, post.id)`? This is thanks to the new
`Phoenix.Param` protocol that lets you define how resources should be
converted to paths and URLs. You may have also noticed the `method:
:delete` option. This will convert the link tag into a form submission,
as a DELETE request, and will inject the CSRF token for you. It's
handy for quick links to delete or update a resource without having to
build a form yourself.


## Resource Generator

The Ecto integration includes a new `mix phoenix.gen.resource` task
that bootstraps a model with boilerplate code generation that lets you
get up to speed quickly with Phoenix and Ecto and start building
applications right away. From a single command like:

```console
mix phoenix.gen.resource Post posts title:string rank:integer
```

A migration file is created with the provided schema and the model,
view, template, and controller files are generated for CRUD actions.
It's a great way to learn the basics of Phoenix and experience the
latest and greatest Ecto features.


## Upgrading from 0.9.x

See these [0.9.x to 0.10.0 upgrade instructions](https://gist.github.com/chrismccord/cf51346c6636b5052885) to bring your existing apps up to speed.

## Get Involved


That's Phoenix 0.10.0. In case you missed it in the previous release, we have done many improvements to our channel system, including support for 3rd party backends, starting with Redis. Now we have streamlined the development experience. We have some big announcements coming soon as
we head towards 1.0, so keep up to date by subscribing to the
[phoenix-core](https://groups.google.com/forum/#!forum/phoenix-core) and [phoenix-talk](https://groups.google.com/forum/#!forum/phoenix-talk) mailing lists, and get involved on
[#elixir-lang IRC](irc://irc.freenode.net/elixir-lang). Feel free to join in and ask questions, and provide
help to others.

Happy coding!
