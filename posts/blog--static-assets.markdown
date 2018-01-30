---
title: Static Assets 
created: 2016-07-28
phoenix_version: v1.3.0
---

# Static Assets

Instead of implementing its own asset pipeline, Phoenix uses [Brunch](http://brunch.io), a fast and developer-friendly asset build tool. Phoenix comes with a default configuration for Brunch, which works out of the box for Javascript and CSS, and it is very easy to bend it to our needs by adding support for various script and style languages, like CoffeeScript, TypeScript, or LESS.

Brunch has [a good tutorial](https://github.com/brunch/brunch-guide), which should be enough to get us started with asset management from the Phoenix perspective.


#### Installation

Brunch is a [Node.js](https://nodejs.org/) application. A newly generated Phoenix project contains `package.json` which lists packages for installation with [npm](https://www.npmjs.com/), the Node Package Manager. If we agree to install dependencies when running `mix phoenix.new`, Phoenix will run `npm` for us. If we don't, or if we change `package.json`, we can always do this ourselves:

```
npm install
```

This will install Brunch and its plugins into the `node_modules` directory.


#### Default Configuration And Workflow

The second important file is `brunch-config.js`. This is configuration for Brunch itself. Let's see how it configures asset management for Phoenix.

According to this configuration Brunch will look for asset source files in `assets`.

Files and directories in `assets/static` will be copied to the destination `priv/static/` without changes.  Only the assets included in the `:only` option to Plug.Static in endpoint.ex are mounted at the root path.  By default only js, css, images, and robots.txt are exposed.

The `css` and `js` directories inside of `assets` are a convention. Brunch will simply look for all files in `assets` excluding `assets/static` and sort all found files by their type.

Processed and concatenated javascript will be put into `priv/static/js/app.js`, styles will be in `priv/static/css/app.css`.

When Phoenix is running, asset source files are processed automatically when changed, but we can also run Brunch ourselves:

```
node node_modules/brunch/bin/brunch build
```

Or we can install Brunch globally:

```
npm install -g brunch
```

and then building assets is as simple as

```
brunch build
```

In addition to Javascript files found in `assets` the following source files will always be included into `priv/static/js/app.js`:

- Brunch's  "bootstrapper" code which provides module management and `require()` logic
- Phoenix Channels JavaScript client (`deps/phoenix/assets/js/phoenix.js`)
- Some code from Phoenix.HTML (`deps/phoenix_html/assets/js/phoenix_html.js`)


#### Modules

By default each Javascript file will be wrapped in a module, and for this code to be executed it needs to be required and executed from another module. Brunch uses a file path without an extension as the name of a module. Let's see how it works.

Brunch in Phoenix is configured to use ES6, so we can use ES6 module syntax.

Open `assets/js/app.js` and add the following code:

```javascript
export var App = {
  run: function(){
    console.log("Hello!")
  }
}
```

If this ES6 syntax seems new, this code is essentially the same as the following more familiar CommonJS module syntax:


```javascript
var App = {
  run: function run() {
    console.log("Hello!");
  }
};

module.exports = {
  App: App
};
```

Open default application layout `lib/hello_web/templates/layout/app.html.eex`, find line

```html
<script src="<%= static_path(@conn, "/js/app.js") %>"></script>
```

and add the following code below:

```html
<script>require("js/app").App.run()</script>
```

When we load this page we should see `Hello!` in the browser Javascript console.

Take notice of `"assets/js/app"`. This is not really a file name, this is the name of a module into which Brunch wrapped the code in `"assets/js/app.js"`


Let's add one more file `assets/js/greeter.js`:

```javascript
export var Greet = {
  greet: function(){
    console.log("Hello!")
  }
}

export var Bye = {
  greet: function(){
    console.log("Bye!")
  }
}
```

and modify `assets/js/app.js` to require the new module:

```javascript
import { Greet } from "./greeter"

export var App = {
  run: function(){
    Greet.greet()
  }
}
```

Please reload the page. We should see `Hello!` in the browser Javascript console.

Object `Bye` was not imported into package `"assets/js/app"`, even though `Bye` is declared as exportable.

Please pay attention to how differently we required module `assets/js/app.js` from the HTML page, and how we imported module `assets/js/greeter` from `assets/js/app`. This is because there is no preprocessing happening for HTML pages and we cannot use ES6 syntax.


#### Legacy Non-modularized Code

If we have some legacy Javascript code which doesn't play well with module systems and/or we need global variables it defines, all we need to do is place our Javascript into directory `assets/vendor`. Brunch will not wrap these files in modules.

Let's test it. Create `assets/vendor` if it does not exist yet and create file `assets/vendor/meaning_of_life.js` with just one line in it:

```
meaning_of_life = 42;
```

Reload the page. Open the JS console and type `meaning_of_life`. This will return `42`. The variable is global.

Important detail: according to the default configuration there is no ES6 support for files in `assets/vendor`. Should we need to enable it, look for `plugins: { babel: { ignore:` in `brunch-config.js`.

#### JavaScript Libraries

We may need to use a JavaScript library like jQuery or underscore in our application. As we mentioned above, we could copy the libraries into `assets/vendor`. It may be a little bit easier to use `npm` to install it: We can simply add `"jquery": ">= 2.1"` to the dependencies in the `package.json` file in our projects root and run `npm install --save`. If the `npm` section in our `brunch-config.js` has a `whitelist` property, we will also need to add "jquery" to that. Now we can `import $ from "jquery"` in our module inside`app.js`.

 If we already have code that assumes jQuery is available as a global variable, we’ll either need to migrate our code (which is a must-do in the long run), or leave jQuery as a non-wrapped codebase (which is acceptable as a transition hack).

To do so, you would add a `globals` definition into the config. For example, if we wanted to expose jQuery globally as `$`, we would modify the config to look like this:

```javascript
  npm: {globals: {
    $: 'jquery',
    jQuery: 'jquery'
  }},
```

Additionally, some packages ship with stylesheets. To instruct Brunch to add these into the build, use the styles property in the npm config. For example, if we installed the Pikaday package and wanted to include its styles, we'd adjust the config like this:

```javascript
npm: {styles: {
    bootstrap: ['dist/css/bootstrap.min.css']
  }},
```

#### Brunch Plugin Pipeline

All transformations Brunch performs are actually done by plugins. Brunch automatically uses installed plugins listed in  `package.json`. Here is what the pipeline looks like for a  newly generated Phoenix project:

##### Javascript

- [`babel-brunch`](https://github.com/babel/babel-brunch) transpiles ES6 code to vanilla ES5 Javascript using [Babel](https://github.com/babel/babel)
- [`javascript-brunch`](https://github.com/brunch/javascript-brunch) is the main Javascript processing plugin. Without it Javascript files will be ignored.
- [`uglify-js-brunch`](https://github.com/brunch/uglify-js-brunch) minifies Javascript code

##### CSS

- [`clean-css-brunch`](https://github.com/brunch/clean-css-brunch) is a minifier for CSS
- [`css-brunch`](https://github.com/brunch/css-brunch) is the main CSS processing plugin. Without it  CSS files will be ignored.


It is very easy to add more plugins. We can find a plethora of Brunch plugins [on the Brunch website](http://brunch.io/plugins.html) and [among NPM packages](https://www.npmjs.com/search?q=brunch).

The order in which plugins run is defined by the order in which they appear in `package.json`.

Let's add support for CoffeeScript. Edit `package.json` by adding the following line **before** `javascript-brunch`:

```json
  "coffee-script-brunch": "^2",
```

and run

```
npm install
```

Let's rename `greeter.js` into `greeter.coffee` and modify its contents to look like the following:

```coffeescript
Greet =
  greet: -> console.log("Hello!")

Bye =
  greet: -> console.log("Bye!")

module.exports =
  Greet: Greet
  Bye: Bye
```

Once Brunch has built our assets, reload our page, and we should see `Hello!` in the browser Javascript console, just like before.

Adding support for other languages like SASS or TypeScript is as simple as this. Some plugins can be configured in `brunch-config.js`, but they will all work out of the box once installed.

#### Other Things Possible With Brunch

There are many more nice tricks we can do with Brunch which are not covered in this guide. Here are just a few:

- It is possible to have [multiple build targets](https://github.com/brunch/brunch-guide/blob/master/content/en/chapter04-starting-from-scratch.md#split-targets), for example, `app.js` for our code and `vendor.js` for third-party libraries
- It is possible to control the order of concatenation of files. This might be necessary when working with JS files in `vendor` if they depend on each other.
- Instead of manually copying third-party libraries into `assets/vendor` we can [use Bower to download and install them](https://github.com/brunch/brunch-guide/blob/master/content/en/chapter05-using-third-party-registries.md).


Should we want one of these, please read [the Brunch documentation](http://brunch.io/docs/getting-started).

#### Phoenix Without Brunch

Should we decide not to use Brunch in our new Phoenix project, run the project generator task with option `--no-brunch`:

```
mix phoenix.new --no-brunch my_project
```

####  Using Another Asset Management System in Phoenix

To integrate another asset management system with Phoenix we will need to

- configure that asset management system to put built assets into `priv/static/`.
- let Phoenix know how to run a command which would watch asset source files and build assets on each change

While the first point is clear, how does Phoenix know which command to run to launch an asset build tool in watch mode? If we open `config/dev.exs` we will find configuration key `:watchers`. `:watchers` is a list of tuples containing an executable and its arguments. That is, with a config like the following:

```elixir
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch"]]
```

the command launched in the development mode is

```
node node_modules/brunch/bin/brunch  watch
```

Let's see how we can integrate [Webpack](http://webpack.github.io) to work with Phoenix. First we generate a project without Brunch support:


```
mix phoenix.new --no-brunch my_project
```

or remove Brunch from the project:

```
rm brunch-config.js && rm -rf node_modules/*
```

Modify `package.json`:

```json
{
  "devDependencies": {
    "webpack": "^1.11.0"
  }
}
```

Install webpack:


```
npm install
```

Create webpack configuration file `webpack.config.js`:

```javascript
module.exports = {
  entry: "./assets/js/app.js",
  output: {
    path: "./priv/static/js",
    filename: "app.js"
  }
};
```

Now we let Phoenix know how to run Webpack. Replace the `:watchers` definition by the following:

```elixir
watchers: [node: ["node_modules/webpack/bin/webpack.js", "--watch", "--color"]]
```

When we restart Phoenix, webpack will be rebuilding assets as they are changed.

Please note that this configuration is very basic. This is just a demonstration of how another asset build tool can be integrated with Phoenix. Please refer to [Webpack documentation](http://webpack.github.io/docs/) for details.