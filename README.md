# PhoenixSite

**This project is archived**. The guides have been moved [to the Phoenix repo](https://github.com/phoenixframework/phoenix/tree/master/guides).

## Pre requisites

Elixir 1.6 **or below** is required.

## Setup

1. Fetch dependencies

```console

$ mix deps.get
$ npm install -g purifycss
```

2. Build the site

To publish all content to S3, simply run `mix site.build`


## Blog/News naming convention

Blog posts are normal obelisk posts, but are specially named with a `"blog--"` filename prefix. Pages must have a `.markdown` extension. The published pages will be uploaded to S3 with the file basename.
