---
title: Upgrading from v1.0 to v1.1
author: Lance Halverson
created: 2015-12-27
phoenix_version: v1.0.0
---

# Phoenix 1.0.x to 1.1.0 upgrade instructions

Please use the gist if you have issues https://gist.github.com/chrismccord/557ef22e2a03a7992624

## Deps

Update your `phoenix`, `phoenix_html` deps, and if using ecto, update your `phoenix_ecto` dep

```elixir
# mix.exs
def deps do
  [{:phoenix, "~> 1.1"},
   {:phoenix_ecto, "~> 2.0"},
   {:phoenix_html, "~> 2.3"},
   ...]
end
```

Now run `$ mix deps.update phoenix phoenix_html phoenix_ecto`


## View / Template Changes

The `@inner` assign has been removed in favor of explicit rendering with `render/3` and the new `@view_module` and `view_template` assigns.

In your `web/templates/layout/app.html.eex` (and other layouts), replace:

    <%= @inner %>
    
with:

    <%= render @view_module, @view_template, assigns %>


## Ecto Changes

Ecto 1.1 has renamed `Ecto.Model` to `Ecto.Schema` and moved many Model functions to the `Ecto` module. Update your `web/web.ex` blocks:

```diff
def model do
  quote
-   use Ecto.Model
+   use Ecto.Schema

+   import Ecto
    import Ecto.Changeset
    ...  
  end 
end

def controller do
  quote
    ...
    alias MyApp.Repo
+   import Ecto
    import Ecto.Query, only: [from: 1, from: 2]
    ...  
  end 
end

def channel do
  quote
    ...
    alias MyApp.Repo
+   import Ecto
    import Ecto.Query, only: [from: 1, from: 2]
    ...  
  end 
end
```

## Gettext (optional)

Gettext has been added for internationalization and localization support.
See the [Gettext docs](http://hexdocs.pm/gettext/Gettext.html) for full details.

To add Gettext support to your application first add `:gettext` to your deps in `mix.exs`:

```elixir
def deps do
  [...,
   {:gettext, "~> 0.9"},
   ...]
end
```

Next, in `mix.exs`, add the `:gettext` compiler to your `project` and `:gettext` to your `:applications` list in `application` list:

```diff
def project do
  [...,
-  compilers: [:phoenix] ++ Mix.compilers,
+  compilers: [:phoenix, :gettext] ++ Mix.compilers,
  ...]
end

def application do
  [mod: {MyApp, []},
-  applications: [:phoenix, :phoenix_html, :cowboy, :logger,
-                 :phoenix_ecto, :postgrex]]
+  applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
+                 :phoenix_ecto, :postgrex]]
end
```

Next, run `$ mix deps.get`

Now, create a `gettext.ex` file at `web/gettext.ex` with the following contents:


```elixir
defmodule MyApp.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](http://hexdocs.pm/gettext),
  your module gains a set of macros for translations, for example:

      import MyApp.Gettext

      # Simple translation
      gettext "Here is the string to translate"

      # Plural translation
      ngettext "Here is the string to translate",
               "Here are the strings to translate",
               3

      # Domain-based translation
      dgettext "errors", "Here is the error message to translate"

  See the [Gettext Docs](http://hexdocs.pm/gettext) for detailed usage.
  """
  use Gettext, otp_app: :my_app
end
```

Replace `MyApp` with your app module and `:my_app` with your otp app.

Next run the following commands from your app root to add necessary gettext supporting files:

```console
$ mkdir -p priv/gettext/en/LC_MESSAGES
$ curl https://raw.githubusercontent.com/phoenixframework/phoenix/277eb7dd03366b336458ffe8dbf637c133b595f0/installer/templates/new/priv/gettext/en/LC_MESSAGES/errors.po > priv/gettext/en/LC_MESSAGES/errors.po
$ curl https://raw.githubusercontent.com/phoenixframework/phoenix/277eb7dd03366b336458ffe8dbf637c133b595f0/installer/templates/new/priv/gettext/errors.pot > priv/gettext/errors.pot
```

Next, create a `web/views/error_helpers.ex` and add these contents:

```elixir
defmodule MyApp.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """
  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    if error = form.errors[field] do
      content_tag :span, translate_error(error), class: "help-block"
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file. On your own code and templates,
    # this could be written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #
    Gettext.dngettext(MyApp.Gettext, "errors", msg, msg, opts[:count], opts)
  end

  def translate_error(msg) do
    Gettext.dgettext(MyApp.Gettext, "errors", msg)
  end
end
```

And now you can import `Gettext` and `MyApp.ErrorHelpers` into your `web.ex` `view` block:

```diff
      import MyApp.Router.Helpers
+     import MyApp.ErrorHelpers
+     import MyApp.Gettext
```

## ChangesetView changes

Changests are no longer encoded to errors when encoding to JSON. The changeset errors should be rendered explicitly. Update your `web/views/changeset_view.ex` (if it exists) with the following code:

```elixir
defmodule MyApp.ChangesetView do
  use MyApp.Web, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `MyApp.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: translate_errors(changeset)}
  end
end
```

If you are not using Gettext with the `ErrorHelpers` module, add this function to your `ChangesetView`:

```elixir
def translate_error({msg, opts}) do
  String.replace(msg, "%{count}", to_string(opts[:count]))
end
def translate_error(msg), do: msg
```

## Channels JavaScript Client changes

`after` hooks have been replaced by a timeout option on `push`, and a `receive("timeout", callback)` hook.

```javascript
// 1.0.x
channel.push("new_message", {body: "hi!"})
       .receive("ok", resp => console.log(resp) )
       .after(5000, () => console.log("times! up"))

channel.push("new_message", {body: "hi!"})
       .receive("ok", resp => console.log(resp) )
       .after(12000, () => console.log("times! up"))

// 1.1.0
// timeout default to 5000
channel.push("new_message", {body: "hi!"}) 
       .receive("ok", resp => console.log(resp) )
       .receive("timeout", () => console.log("times! up"))

// custom timeout as optional 3rd arg
channel.push("new_message", {body: "hi!"}, 12000)
       .receive("ok", resp => console.log(resp) )
       .receive("timeout", () => console.log("times! up"))
```
