---
title: Upgrading from v1.2 to v1.3
author: Chris McCord
created: 2017-07-27
phoenix_version: v1.3.0
---

If you want a run-down of the 1.3 changes and the design decisions behidn those changes, check out the LonestarElixir Phoenix 1.3 keynote: https://www.youtube.com/watch?v=tMO28ar0lW8

To use the new `phx.new` project generator, you can install the archive with the following command:

    $ mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez

## Bump your phoenix dep
Phoenix v1.3.0 is a backwards compatible release with v1.2.x. To upgrade your existing 1.2.x project, simply bump your phoenix dependency in `mix.exs`:

```elixir
def deps do
  [{:phoenix, "~> 1.3.0"},
   ...]
end
```

## Update your static manifest location

If using the digest task (mix phoenix.digest), the location of the built manifest has changed from `priv/static/manifest.json` to `priv/static/cache_manifest.json`. Update your `config/prod.exs` endpoint config with the following changes:

```diff
-cache_static_manifest: "priv/static/manifest.json"
+cache_static_manifest: "priv/static/cache_manifest.json"
```

Next, run `mix deps.get` and you're all set! Continue reading to jump on the latest project structure conventions (optional).


## Update your project the new 1.3 directory structure (optional)

### mix.exs

In `mix.exs`, update your `elixirc_paths/1` clauses to remove "web":

```diff
- defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
- defp elixirc_paths(_),     do: ["lib", "web"]
+ defp elixirc_paths(:test), do: ["lib", "test/support"]
+ defp elixirc_paths(_),     do: ["lib"]
```

If you have a `reloadable_paths` configuration in your `config/dev.exs`, you may remove this value as all `elixirc_paths` are now reloaded in dev by default.

### Move your root-level `web/` directory to `lib/app_name_web`, and migrate to new `Web` namespace

The root level `web/` directory for new projects has been removed in favor of `lib/my_app_web`. Additionally, a `Web` namespace convention has been added to isolate the web interface from your elixir application.

Migrate your files to the new structure with the following steps:

1. `$ cd my_app`
1. `$ mv web/web.ex lib/my_app_web.ex`
1. `$ mv web lib/my_app_web`
1. `$ mv lib/my_app/endpoint.ex lib/my_app_web/`
1. Update your view root path in `lib/my_app_web.ex` to point to the new template location, and add the `:namespace` option:

   ```diff
     def view do
       quote do
   -      use Phoenix.View, root: "web/templates"
   +      use Phoenix.View, root: "lib/my_app_web/templates",
   +                        namespace: MyAppWeb
          ...
   ```

1. Add the namespace option to your `controller` definition in `web.ex`:

   ```diff
     def controller do
       quote do
   -     use Phoenix.Controller
   +     use Phoenix.Controller, namespace: MyAppWeb
   ```

1. Update your aliases in web.ex `controller`, `view`, and `channel` definitions to use the new `Web` namespace:

   ```diff
     def controller do
       quote do
         ...
   -     import MyApp.Router.Helpers
   +     import MyAppWeb.Router.Helpers
   -     import MyApp.Gettext
   +     import MyAppWeb.Gettext
       end
     end

     def view do
       quote do
         ...
   -     import MyApp.Router.Helpers
   +     import MyAppWeb.Router.Helpers
   -     import MyApp.ErrorHelpers
   +     import MyAppWebErrorHelpers
   -     import MyApp.Gettext
   +     import MyAppWeb.Gettext
       end
     end

     def channel do
       quote do
         ...
   -     import MyApp.Gettext
   +     import MyAppWeb.Gettext
       end
     end
   ```

1. Rename all web related modules in `lib/my_app_web/` (`gettext.ex`, `controllers/*`, `views/*`, `channels/*`, `endpoint.ex`, `router.ex`) to include a `Web` namespace, for example:

   * `MyApp.Endpoint` => `MyAppWeb.Endpoint`
   * `MyApp.Router` => `MyAppWeb.Router`
   * `MyApp.PageController` => `MyAppWeb.PageController`
   * `MyApp.PageView` => `MyAppWeb.PageView`
   * `MyApp.UserSocket` => `MyAppWeb.UserSocket`
   * etc

1. Update all aliases in `lib/app_name_web/router.ex` to include new `Web` namespace. Most likely you can accomplish this by adding `Web` to the second argument of your scope blocks, for example:

   ```diff
   - defmodule MyApp.Router do
   + defmodule MyAppWeb.Router do
     ...
   -   scope "/", MyApp do
   +   scope "/", MyAppWeb do
         pipe_through :browser

         resources "/users", UserController
         ...
      end
   ```

1. Update `endpoint.ex` to use new web modules:

   ```diff
   - defmodule MyApp.Endpoint do
   + defmodule MyAppWeb.Endpoint do
       ...
   -   socket "/socket", MyApp.UserSocket
   +   socket "/socket", MyAppWeb.UserSocket
       ...
   -   plug MyApp.Router
   +   plug MyAppWeb.Router
   ```

1. Rename `lib/my_app.ex` to `lib/my_app/application.ex` and `MyApp` to `MyApp.Application`
1. in `mix.exs`, change `mod: {MyApp, []}` to `mod: {MyApp.Application, []}`
1. in `lib/my_app/application.ex`, update your children to reference the new endpoint and remove the `config_change` callback:

   ```diff
       ...
       children = [
         ...
   -     supervisor(MyApp.Endpoint, []),
   +     supervisor(MyAppWeb.Endpoint, []),
         ...
       ]

     ...
   - def config_change(changed, _new, removed) do
   -   MyApp.Endpoint.config_change(changed, removed)
   -   :ok
   - end
   ```

1. Update all endpoint aliases in `config/*.exs` (`config.exs`, `prod.exs`, `prod.secret.exs`, `dev.exs`, `test.exs`, etc) to use new `Web` namespace:

   ```diff
   - config :my_app, MyApp.Endpoint,
   + config :my_app, MyAppWeb.Endpoint,
       ...
   -   render_errors: [view: MyApp.ErrorView, accepts: ~w(html json)],
   +   render_errors: [view: MyAppWeb.ErrorView, accepts: ~w(html json)],
     ...
   ```

1. Update your live-reload patterns config in `config/dev.exs`:

   ```diff
   - config :my_app, MyApp.Endpoint,
   + config :my_app, MyAppWeb.Endpoint,
       live_reload: [
         patterns: [
           ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
           ~r{priv/gettext/.*(po)$},
   -       ~r{web/views/.*(ex)$},
   -       ~r{web/templates/.*(eex)$}
   +       ~r{lib/my_app_web/views/.*(ex)$},
   +       ~r{lib/my_app_web/templates/.*(eex)$}
         ]
       ]
   ```

1. Rename your `test/support/conn_case.ex` and `test/support/channel_case.ex` modules to include `Web` namespace, and update `@endpoint` and router aliases in each:

   ```diff
   -defmodule MyApp.ConnCase do
   +defmodule MyAppWeb.ConnCase do
     using do
       quote do
         ...
   -     import MyApp.Router.Helpers
   +     import MyAppWeb.Router.Helpers

         # The default endpoint for testing
   -     @endpoint MyApp.Endpoint
   +     @endpoint MyAppWeb.Endpoint
       end
     end
     ...


   -defmodule MyApp.ChannelCase do
   +defmodule MyAppWeb.ChannelCase do

     using do
       quote do
         ...
   -     @endpoint MyApp.Endpoint
   +     @endpoint MyAppWeb.Endpoint
       end
     end
     ...
   ```

1. Update all `test/*/**.exs` references to `use MyApp.ConnCase` or `use MyApp.ChannelCase` to use new `MyAppWeb.ConnCase` and `MyAppWeb.ChannelCase` aliases.

### Move static assets inside self-contained assets/ directory

New projects now include a root-level `assets/` directory, which serves as a self-contained location for your asset builder's config, source files, and packages. This changer keeps things like `node_modules`, `package.json`, and `brunch-config.js` from leaking into the root of your elixir application. Update your app to the new structure by following these steps:

1. move all `web/static/` sources into `assets/`, followed by `package.json`, `node_modules`, and `brunch-config.js`

   ```console
   $ mv mv lib/my_app_web/static assets/
   $ mv assets/assets assets/static
   $ mv package.json assets/
   $ mv brunch-config.js assets/
   $ rm -rf node_modules
   ```

1. Update your `asset/package.json` `phoenix` and `phoenix_html` paths:

   ```diff
     "dependencies": {
   -   "phoenix": "file:deps/phoenix",
   +   "phoenix": "file:../deps/phoenix",
   -   "phoenix_html": "file:deps/phoenix_html"
   +   "phoenix_html": "file:../deps/phoenix_html"
     },
   ```


1. Update your `assets/brunch-config.js` to be aware of the new conventions:

   ```diff
     conventions: {
   -   // This option sets where we should place non-css and non-js assets in.
   -   // By default, we set this to "/web/static/assets". Files in this directory
   -   // will be copied to `paths.public`, which is "priv/static" by default.
   -   assets: /^(web\/static\/assets)/
   +   // This option sets where we should place non-css and non-js assets in.
   +   // By default, we set this to "/assets/static". Files in this directory
   +   // will be copied to `paths.public`, which is "priv/static" by default.
   +   assets: /^(static)/
     },

     paths: {
       // Dependencies and current project directories to watch
   -   watched: [
   -     "web/static",
   -     "test/static"
   -   ],
   +   watched: ["static", "css", "js", "vendor"],

       // Where to compile files to
   -   public: "priv/static"
   +   public: "../priv/static"
     },

     plugins: {
       babel: {
         // Do not use ES6 compiler in vendor code
   -     ignore: [/web\/static\/vendor/]
   +     ignore: [/vendor/]
       }
     },

     modules: {
       autoRequire: {
   -     "js/app.js": ["web/static/js/app"]
   +     "js/app.js": ["js/app"]
       }
     },
   ```

1. Update your `config/dev.exs` watcher to run in the new assets directory:

   ```diff
   config :my_app, MyAppWeb.Endpoint,
     ...
     watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
   -                  cd: Path.expand("../", __DIR__)]]
   +                  cd: Path.expand("../assets", __DIR__)]]


   ```

1. Install the node deps: `$cd assets && npm install`


Test it all with `mix phx.server`, and `mix test` and you should see:

```
$ mix phx.server
[info] Running MyAppWeb.Endpoint with Cowboy using http://0.0.0.0:4000
01 Mar 15:40:05 - info: compiled 6 files into 2 files, copied 3 in 976ms
```
