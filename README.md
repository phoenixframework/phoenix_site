# PhoenixSite

> Phoenix Guides landing page publisher


## Setup

1. Install `awscli`

```console
$ brew install awscli
```

see the [awscli docs](http://docs.aws.amazon.com/cli/latest/userguide/cli-install-macos.html#awscli-install-osx-path) for other installation options.

2. Configure your awscli credentials:

```console
$ aws configure
```

3. Fetch mix deps and test local build

```console

$ mix deps.get
$ mix obelisk build
```

Your built static files will be located in `build/`


## Publishing Guides to S3

To publish all content to S3, simply run `mix guides.publish`


## Blog/News naming convention

Blog posts are normal obelisk "pages", but are specially named with a `"blog--"` filename prefix. Pages must have a `.markown` extension. The published pages will be uploaded to S3 with the file basename.
