---
title: Upgrading from v1.3 to v1.4
author: Chris McCord
created: 2019-02-26
phoenix_version: v1.4.0
---

Phoenix 1.4 ships with exciting new features, most notably with HTTP2 support, improved development experience with faster compile times, new error pages, and local SSL certificate generation. Additionally, our channel layer internals receiveced an overhaul, provided better structure and extensibility. We also shipped a new and improved Presence javascript API, as well as Elixir formatter integration for our routing and test DSLs.

This release requires few user-facing changes and should be a fast upgrade for those on Phoenix 1.3.x.

## Install the new phx.new project generator

The mix phx.new archive can now be installed via hex, for a simpler, versioned installation experience.

To grab the new archive, simply run:

```console
$ mix archive.uninstall phx_new
$ mix archive.install hex phx_new 1.4.0
```

## Update Phoenix and Cowboy deps

To get started, simply update your Phoenix dep in `mix.exs`:

```elixir
{:phoenix, "~> 1.4.0"}
```

Next, replace your `:cowboy` dependency with `:plug_cowboy`: 

```elixir
{:plug_cowboy, "~> 2.0"}
{:plug, "~> 1.7"}
```

To upgrade to Cowboy 2 for HTTP2 support, use `~> 2.0` as above. To stay on cowboy 1, pass `~> 1.0`.

Finally, remove your explicit `:ecto` dependency and update your `:phoenix_ecto` and `:ecto_sql` dependencies with the following versions:

```elixir
  ...,
  {:ecto_sql, "~> 3.0"},
  {:phoenix_ecto, "~> 4.0"}
```

After running `mix deps.get`, then be sure to grab the latest npm pacakges with:

```console
$ cd assets
$ npm install
```

## Update your Jason configuration

Phoenix 1.4 uses `Jason` for json generation in favor of poison. Poison may still be used, but you must add `:poison` to your deps to continue using it on 1.4. To use Jason instead, `:jason` to your deps in mix.exs:

```elixir
  ...,
  {:jason, "~> 1.0"},
```

Then add the following configuration in `config/config.exs`:

```elixir
# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
```

## Update your UserSocket

Phoenix 1.4 deprecated the `transport` macro, in favor of providing transport information directly on the `socket` call in your endpoint. Make the following changes:

```diff
# app_web/channels/user_socket.ex
- transport :websocket, Phoenix.Transports.WebSocket
- transport :longpoll, Phoenix.Transports.LongPoll, [check_origin: ...]

# app_web/endpoint.ex
- socket "/socket", MyAppWeb.UserSocket
+ socket "/socket", MyAppWeb.UserSocket, 
+   websocket: true # or list of options
+   longpoll: [check_origin: ...]
```


## Update your Presence javascript

A new, backwards compatible `Presence` JavaScript API has been
introduced to both resolve race conditions as well as simplify the
usage. Previously, multiple channel callbacks against
`"presence_state` and `"presence_diff"` events were required on the
client which dispatched to `Presence.syncState` and
`Presence.syncDiff` functions. Now, the interface has been unified to
a single `onSync` callback and the presence instance tracks its own
channel callbacks and state. For example:


```diff
import {Socket, Presence} from "phoenix"

let renderUsers(presence){
-  someContainer.innerHTML = Presence.list(presence, (id, user) {
-    `<br/>${escape(user.name)}`
-  }.join("")
+  someContainer.innerHTML = presence.list((id, user) {
+    `<br/>${escape(user.name)}`   
+  }).join("")
}

let onJoin = (id, current, newPres) => {
  if(!current){
    console.log("user has entered for the first time", newPres)
  } else {
    console.log("user additional presence", newPres)
  }
}
 
let onLeave = (id, current, leftPres) => {
  if(current.metas.length === 0){
    console.log("user has left from all devices", leftPres)
  } else {
    console.log("user left from a device", leftPres)
  }
})

let channel = new socket.channel("...")
- let presence = {}
- channel.on("presence_state", state => {
-   presence = Presence.syncState(presence, state, onJoin, onLeave)
-   renderUsers(presence)
- })
- channel.on("presence_diff", diff => {
-   presence = Presence.syncDiff(presence, diff, onJoin, onLeave)
-   renderUsers(presence)
- })
+ let presence = new Presence(channel)

+ presence.onJoin(onJoin)
+ presence.onLeave(onLeave)
+ presence.onSync(() => renderUsers(presence))
```


## Optional Updates

The above changes are the only ones necessary to be up and running with Phoenix 1.4. The remaining changes will bring you up to speed with new conventions, but are strictly optional.

### Add formatter support

Phoenix 1.4 includes formatter integration for our routing and test DSLs. Create or ammend your `.formatter.exs` in the root of your project(s) with the following:

```elixir
[
  import_deps: [:phoenix],
  inputs: ["*.{ex,exs}", "{config,lib,priv,test}/**/*.{ex,exs}"]
]
```
### Add a Routes alias and update your router calls

A `Routes` alias has been added to `app_web.ex` for `view` and `controller` blocks in favor over the previously imported `AppWeb.Router.Helpers`.

The new `Routes` alias makes it clearer where `page_path/page_url` and friends exist and removes compile-time dependencies across your web stack. To use the latest conventions, make the following changes to `app_web.ex`:

```diff
- import AppWeb.Router.Helpers
+ alias AppWeb.Router.Helpers, as: Routes
```

Next, update any controllers, views, and templates calling your imported helpers or `static_path|url`, to use the new alias, for example:

```diff
- <%= link "show", to: user_path(@conn, :show, @user) %>
+ <%= link "show", to: Routes.user_path(@conn, :show, @user) %>

- <script type="text/javascript" src="<%= static_url(@conn, "/js/app.js") %>"></script>
+ <script type="text/javascript" src="<%= Routes.static_url(@conn, "/js/app.js") %>"></script>
```

### Replace Brunch with webpack

The `mix phx.new` generator in 1.4 now uses webpack for asset generation instead of brunch. The development experience remains the same – javascript goes in `assets/js`, css goes in `assets/css`, static assets live in `assets/static`, so those not interested in JS tooling nuances can continue the same patterns while using webpack. Those in need of optimal js tooling can benefit from webpack's more sophisticated code bunding, with dead code elimination and more.

To proceed:

* update `assets/package.json` to replace Brunch with webpack:

```diff
   "repository": {},
   "license": "MIT",
   "scripts": {
-    "deploy": "brunch build --production",
-    "watch": "brunch watch --stdin"
+    "deploy": "webpack --mode production",
+    "watch": "webpack --mode development --watch-stdin"
   },
   "dependencies": {
     "phoenix": "file:../deps/phoenix",
     "phoenix_html": "file:../deps/phoenix_html"
   },
   "devDependencies": {
-    "babel-brunch": "6.1.1",
-    "brunch": "2.10.9",
-    "clean-css-brunch": "2.10.0",
-    "uglify-js-brunch": "2.10.0"

+    "@babel/core": "^7.0.0",
+    "@babel/preset-env": "^7.0.0",
+    "babel-loader": "^8.0.0",
+    "copy-webpack-plugin": "^4.5.0",
+    "css-loader": "^0.28.10",
+    "mini-css-extract-plugin": "^0.4.0",
+    "optimize-css-assets-webpack-plugin": "^4.0.0",
+    "uglifyjs-webpack-plugin": "^1.2.4",
+    "webpack": "4.4.0",
+    "webpack-cli": "^2.0.10"
   }
 }
```

* delete `assets/brunch-config.js`
* create `assets/.babelrc` with the following contents:

```json
{
    "presets": [
        "env"
    ]
}
```

* create `assets/webpack.config.js` with the following contents:

```javascript
const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
      './js/app.js': ['./js/app.js'].concat(glob.sync('./vendor/**/*.js'))
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader']
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.css' }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
  ]
});
```

 * Update `config/dev.exs` to use `webpack` instead of `brunch`:

```diff
-  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
+  watchers: [
+    node: [
+      "node_modules/webpack/bin/webpack.js",
+      "--mode",
+      "development",
+      "--watch-stdin",
+      cd: Path.expand("../assets", __DIR__)
+    ]
```

### CSS changes

* The main CSS bundle must now be imported from the `app.js` file. Add the following line to the top of `assets/js/app.js`:

```javascript
import css from '../css/app.css';
```
* If you are using the default css, replace `assets/css/phoenix.css` with the following:

https://raw.githubusercontent.com/phoenixframework/phoenix/89cdcfbaa041da1daba39e39b0828f6a28b6d52f/installer/templates/phx_assets/phoenix.css