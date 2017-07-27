---
title: Upgrading from v1.1.1 to v1.1.2
author: Jason Stiebs
created: 2016-08-17
phoenix_version: v1.0.0
---

https://gist.github.com/chrismccord/29100e16d3990469c47f851e3142f766

## Project Generator

To generate new projects as 1.2.0, install the new mix archive:

    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez
     
## Deps

Update your phoenix dep for phoenix and include the extracted `:phoenix_pubsub` depdendency. If using Ecto, bump your `:phoenix_ecto` dependency as well:

```elixir
# mix.exs
def deps do
  [{:phoenix, "~> 1.2.0"},
   {:phoenix_pubsub, "~> 1.0"},
   # if using Ecto:
   {:phoenix_ecto, "~> 3.0-rc"},
   ...]
end
```

Next, add `:phoenix_pubsub` to your `:applications` list in mix.exs:

```elixir
  def application do
    [mod: {MyApp, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex]]
  end
```

Next, update your deps:

    $ mix deps.update phoenix phoenix_pubsub phoenix_ecto phoenix_live_reload phoenix_html --unlock

## Tests

The `conn/0` helper imported into your tests has been deprecated. use `build_conn/0` instead.

## Ecto 2.0

If using Ecto, update your test_helper.exs:

```diff
ExUnit.start

- Mix.Task.run "ecto.create", ~w(-r Onetwo.Repo --quiet)
- Mix.Task.run "ecto.migrate", ~w(-r Onetwo.Repo --quiet)
- Ecto.Adapters.SQL.begin_test_transaction(Onetwo.Repo)
+ Ecto.Adapters.SQL.Sandbox.mode(MyAPp.Repo, :manual)
```

Next, add the following to `config/config.exs`:

```elixir
config :my_app, ecto_repos: [MyApp.Repo]
```

Next, add a new `test` alias to your `aliases` in mix.exs:

```diff
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
+    "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
```

Next, update your `setup` blocks in `test/support/model_case.ex` and `test/support/channel_case.ex`:

```diff
  setup tags do
-   unless tags[:async] do
-     Ecto.Adapters.SQL.restart_test_transaction(MyApp.Repo, [])
-   end

+   :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)

+   unless tags[:async] do
+     Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, {:shared, self()})
+   end

    :ok
  end
```

And update your `test/support/conn_case.ex`:

```diff
  setup tags do
-   unless tags[:async] do
-     Ecto.Adapters.SQL.restart_test_transaction(MyApp.Repo, [])
-   end

-   {:ok, conn: Phoenix.ConnTest.conn()}
+   :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)

+   unless tags[:async] do
+     Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, {:shared, self()})
+   end

+   {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
```

Passing `:empty` to `cast` has been deprecated. Pass an empty map in your changesets instead:

```diff
-  def changeset(struct, params \\ :empty) do
+  def changeset(struct, params \\ %{}) do
```

## ErrorHelpers

Update your `translate_error` function in `web/views/error_helpers.ex`:

```diff
- @doc """
- Translates an error message using gettext.
- """
- def translate_error({msg, opts}) do
-   # Because error messages were defined within Ecto, we must
-   # call the Gettext module passing our Gettext backend. We
-   # also use the "errors" domain as translations are placed
-   # in the errors.po file. On your own code and templates,
-   # this could be written simply as:
-   #
-   #     dngettext "errors", "1 file", "%{count} files", count
-   #
-   Gettext.dngettext(MyApp.Gettext, "errors", msg, msg, opts[:count], opts)
- end

- def translate_error(msg) do
-   Gettext.dgettext(MyApp.Gettext, "errors", msg)
- end
+def translate_error({msg, opts}) do
+   # Because error messages were defined within Ecto, we must
+   # call the Gettext module passing our Gettext backend. We
+   # also use the "errors" domain as translations are placed
+   # in the errors.po file.
+   # Ecto will pass the :count keyword if the error message is
+   # meant to be pluralized.
+   # On your own code and templates, depending on whether you
+   # need the message to be pluralized or not, this could be
+   # written simply as:
+   #
+   #     dngettext "errors", "1 file", "%{count} files", count
+   #     dgettext "errors", "is invalid"
+   #
+   if count = opts[:count] do
+     Gettext.dngettext(MyApp.Gettext, "errors", msg, msg, count, opts)
+   else
+     Gettext.dgettext(MyApp.Gettext, "errors", msg, opts)
+   end
+ end
```

Next, update your `test/support/model_case.ex`'s `errors_on` function:

```diff
-  def errors_on(model, data) do
-    model.__struct__.changeset(model, data).errors
-  end
  
+  def errors_on(struct, data) do
+    struct.__struct__.changeset(struct, data)
+    |> Ecto.Changeset.traverse_errors(&MyApp.ErrorHelpers.translate_error/1)
+    |> Enum.flat_map(fn {key, errors} -> for msg <- errors, do: {key, msg} end)
+  end
```
## Configuration

### Watcher

Using the `:root` endpoint configuration for watchers is deprecated and can be removed from `config/config.exs`. Instead, pass the `:cd` option at the end of your watcher argument list in `config/dev.exs`. For example:

```elixir
watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
           cd: Path.expand("../", __DIR__)]]
```

### Namespace

Change `app_namespace:` in the application configuration to `namespace:`.

```diff
 config :my_app,
+  namespace: My.App
-  app_namespace: My.App
```

## JavaScript Client

If using brunch, run `npm update phoenix phoenix_html`.

If vendoring the phoenix.js JavaScript client, grab a new copy:
https://raw.githubusercontent.com/phoenixframework/phoenix/v1.2.0/web/static/js/phoenix.js
