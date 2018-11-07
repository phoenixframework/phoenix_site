---
title: Phoenix 1.4.0 released
author: Chris McCord
created: 2018-11-07
phoenix_version: v1.4.0
---

Phoenix 1.4 is out! This release ships with exciting new features, most notably HTTP2 support, improved development experience with faster compile times, new error pages, and local SSL certificate generation. Additionally, our channel layer internals receiveced an overhaul, providing better structure and extensibility. We also shipped a new and improved Presence javascript API, as well as Elixir formatter integration for our routing and testing DSLs.

### phx_new hex archive

The `mix phx.new` archive can now be installed via hex, for a simpler, versioned installation experience.

To grab the new archive, simply run:

```
$ mix archive.uninstall phx_new
$ mix archive.install hex phx_new 1.4.0
```

The new generators also use [Milligram](https://milligram.io) in favor of Bootstrap to support classless markup generation. The result is nice looking defaults that allow generated markup to be much more easily customized to your individual CSS requirements.

**Note**: Existing Phoenix applications will continue to work on Elixir 1.4, but the new `phx.new` archive requires Elixir 1.5+.

### HTTP2

Thanks to the release of Cowboy 2, Phoenix 1.4 supports HTTP2 with a
single line change to your `mix.exs`. Simply add `{:plug_cowboy, "~> 2.5"}` to your deps and Phoenix will run with the Cowboy 2 adapter.


### Local SSL development

Most browsers require connections over SSL for HTTP2 requests,
otherwise they fallback to HTTP 1.1 requests. To aid local development
over SSL, phoenix includes a new `phx.gen.cert` task which generates a
self-signed certificate for HTTPS testing in development.

See the [phx.gen.cert](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Cert.html) docs for more information.

### Faster Development Compilation

Our development compilation speeds have improved thanks to contributions to plug and compile-time changes. You can read more about the details in my [DockYard Phoenix post](https://dockyard.com/blog/2018/02/12/what-s-new-in-phoenix-development-february-2018)

### New Development 404 Page

Our 404 page in development now lists the available routes for the
originating router, for example:

![](//i.imgur.com/sueKW9B.jpg)

### UserSocket connection info

A highly requested feature has been access to more underlying transport information when using Phoenix channels. The 1.4 release now provides a `connect/3` UserSocket callback, which can provide connection information, such as the peer IP address, host information, and X-Headers of the HTTP request for WebSocket and Long-poll transports.

### New Presence JavaScript API

A new, backwards compatible `Presence` JavaScript API has been
introduced to both resolve race conditions as well as simplify the
usage. Previously, multiple channel callbacks against
`"presence_state` and `"presence_diff"` events were required on the
client which dispatched to `Presence.syncState` and
`Presence.syncDiff` functions. Now, the interface has been unified to
a single `onSync` callback and the presence object tracks its own
channel callbacks and state. For example:


```javascript
let presence = new Presence(roomChannel)
presence.onSync(() => {
  console.log("users online:", presence.list((id, {name}) => name))
})
```

That's all there is to it!

### webpack

The  `mix phx.new`  generator now uses webpack for asset generation instead of brunch. The development experience remains the same – javascript goes in  `assets/js` , css goes in  `assets/css` , static assets live in  `assets/static` , so those not interested in JS tooling nuances can continue the same patterns while using webpack. Those in need of optimal js tooling can benefit from webpack's more sophisticated code bunding, with dead code elimination and more.


### What's Next

With the release of 1.4, we're ready to focus on other exciting initiatives around the Elixir and Phoenix ecosystem. Most notably, we are excited to integrate [telemetry](https://github.com/beam-telemetry/telemetry) into Phoenix for metric tracking and visualization. Simultaneously, we are also working to rewrite `Phoenix.PubSub` into smaller building blocks and provide a first-class distributed programming toolkit for the community. You can track this progress over at the [Firenest](https://github.com/phoenixframework/firenest) project.

In addition to telemetry and firenest initiatives, we are also working on `Phoenix.LiveView`, to enable server-rendered real-time experiences without all the complexity of today's single page application landscape. LiveView can enable rich UX on par with single-page apps in certain usecases and we can't wait to get the initial release out to the community.

My ElixirConf keynote covers telemetry and LiveView in detail:

<iframe width="560" height="315" src="https://www.youtube.com/embed/Z2DU0qLfPIY" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


### Programming Phoenix Book

The [Programming Phoenix Book](https://pragprog.com/book/phoenix14/programming-phoenix-1-4) 
is in beta and available through PragProg, and includes all the latest changes for 1.4.
We have titled the book ">= 1.4" and consider it relatively future proof as we continue
minor version releases.

### Special Thank You's

I would like to specially thank Loïc Hoguin for his work on Cowboy 2,
allowing us to provide a first-class HTTP2 experience. We would also like to thank Bram Verburg, who contributed the local SSL certificate generation, for cross-platform, dependency-free cert generation.

Additionally, I would like to thank José Valim and [Plataformatec](http://plataformatec.com.br) for their work on the channel layer overhaul which provides an extensible foundation going forward.

As always, we have provided step-by-step instructions for bringing your 1.3.x apps up to speed:
https://gist.github.com/chrismccord/bb1f8b136f5a9e4abc0bfc07b832257e

Please report issues to the issue tracker, and find us on
#elixir-lang irc, elixir slack, and the Elixir forum if you have any
questions. The full list of changes from the changelog can be found below.

Happy hacking!

–Chris


### Changlog

#### Enhancements
  * [phx.new] Update Ecto deps with the release of Ecto 3.0 including `phoenix_ecto` 4.0
  * [phx.new] Import Ecto's `.formatter.exs` in new projects 
  * [phx.new] Use Ecto 3.0RC, with `ecto_sql` in new project deps
  * [phx.new] Use Plug 1.7 with new `:plug_cowboy` dependency for cowboy adapter
  * [phx.gen.html|json|schema|context] Support new Ecto 3.0 usec datetime types
  * [Phoenix] Add `Phoenix.json_library/0` and replace `Poison` with `Jason` for JSON encoding in new projects
  * [Endpoint] Add `Cowboy2Adapter` for HTTP2 support with cowboy2
  * [Endpoint] The `socket/3` macro now accepts direct configuration about websockets and longpoll
  * [Endpoint] Support MFA function in `:check_origin` config for custom origin checking
  * [Endpoint] Add new `:phoenix_error_render` instrumentation callback
  * [Endpoint] Log the configured url instead of raw IP when booting endpoint webserver
  * [Endpoint] Allow custom keyword pairs to be passed to the socket `:connect_info` options.
  * [Router] Display list of available routes on debugger 404 error page
  * [Router] Raise on duplicate plugs in `pipe_through` scopes
  * [Controller] Support partial file downloads with `:offset` and `:length` options to `send_download/3`
  * [Controller] Add additional security headers to `put_secure_browser_headers` (`x-content-type-options`, `x-download-options`, and `x-permitted-cross-domain-policies`)
  * [Controller] Add `put_router_url/2` to override the default URL generation pulled from endpoint configuration
  * [Logger] Add whitelist support to `filter_parameters` logger configuration, via new `:keep` tuple format
  * [Socket] Add new `phoenix_socket_connect` instrumentation
  * [Socket] Improve error message when missing socket mount in endpoint
  * [Logger] Log calls to user socket connect
  * [Presence] Add `Presence.get_by_key` to fetch presences for specific user
  * [CodeReloader] Add `:reloadable_apps` endpoint configuration option to allow recompiling local dependencies
  * [ChannelTest] Respect user's configured ExUnit `:assert_receive_timeout` for macro assertions


#### Bug Fixes
  * Add missing `.formatter.exs` to hex package for proper elixir formatter integration
  * [phx.gen.cert] Fix usage inside umbrella applications
  * [phx.new] Revert `Routes.static_url` in app layout in favor of original `Routes.static_path`
  * [phx.new] Use phoenix_live_reload 1.2-rc to fix hex version errors
  * [phx.gen.json|html] Fix generator tests incorrectly encoding datetimes
  * [phx.gen.cert] Fix generation of cert inside umbrella projects
  * [Channel] Fix issue with WebSocket transport sending wrong ContentLength header with 403 response
  * [Router] Fix forward aliases failing to expand within scope block
  * [Router] Fix regression in router compilation failing to escape plug options

#### phx.new installer
  * Generate new Elixir 1.5+ child spec (therefore new apps require Elixir v1.5)
  * Use webpack for asset bundling

#### Deprecations
  * [Controller] Passing a view in `render/3` and `render/4` is deprecated in favor of `put_view/2`
  * [Endpoint] The `:handler` option in the endpoint is deprecated in favor of `:adapter`
  * [Socket] `transport/3` is deprecated. The transport is now specified in the endpoint
  * [Transport] The transport system has seen an overhaul and been drastically simplified. The previous mechanism for building transports is still supported but it is deprecated. Please see `Phoenix.Socket.Transport` for more information

#### JavaScript client
  * Add new instance-based Presence API with simplified synchronization callbacks
  * Accept a function for socket and channel `params` for dynamic parameter generation when connecting and joining
  * Fix race condition when presence diff arrives before state
  * Immediately rejoin channels on socket reconnect for faster recovery after reconnection
  * Fix reconnect caused by pending heartbeat

