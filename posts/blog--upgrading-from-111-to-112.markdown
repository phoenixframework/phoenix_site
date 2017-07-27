---
title: Upgrading from v1.1.1 to v1.1.2
author: Jason Stiebs
created: 2016-01-27
phoenix_version: v1.0.0
---

## Phoenix 1.1.1 to 1.1.2 upgrade instructions

Check out https://gist.github.com/chrismccord/d5bc5f8e38c8f76cad33 for latest details
> Optional upgrade for new brunch features

### Update your phoenix deps

```elixir
def deps do
  [{:phoenix, "~> 1.1.2"},
  ...]
end
```

Now, update your phoenix deps to grab the latest minor releases:

```console
$ mix deps.update phoenix phoenix_html phoenix_live_reload
```

### Update your `package.json`
> (for umbrellas the `file` prefix will need `file:../../deps/`)

```javascript
{
  "repository": {
  },
  "dependencies": {
    "babel-brunch": "^6.0.0",
    "brunch": "^2.1.1",
    "clean-css-brunch": ">= 1.0 < 1.8",
    "css-brunch": ">= 1.0 < 1.8",
    "javascript-brunch": ">= 1.0 < 1.8",
    "uglify-js-brunch": ">= 1.0 < 1.8",
    "phoenix": "file:deps/phoenix",
    "phoenix_html": "file:deps/phoenix_html"
  }
}
```

And run `$ npm install` to bring in the new node deps

### Update you brunch-config.js:

Remove phoenix and phoenix_html from your `watched` configuration:

```diff
  paths: {
    // Dependencies and current project directories to watch
    watched: [
-     "deps/phoenix/web/static",
-     "deps/phoenix_html/web/static",
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },
```

Add `npm.whitelist` to your `npm` config:

```diff
  npm: {
    enabled: true,
+   whitelist: ["phoenix", "phoenix_html"]
  }
```

### Update your js imports

```diff
- import "deps/phoenix_html/web/static/js/phoenix_html"
+ import "phoenix_html"

- import {Socket} from "deps/phoenix/web/static/js/phoenix"
+ import {Socket} from "phoenix"
```


## Test it

    $ mix phoenix.server
    07 Jan 16:16:59 - info: compiled 5 files into 2 files, copied 3 in 1.2 sec
