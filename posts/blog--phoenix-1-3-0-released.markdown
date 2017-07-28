---
title: Phoenix 1.3.0 released
author: Chris McCord
created: 2017-07-28
phoenix_version: v1.3.0
---

Phoenix 1.3.0 is out! This release focuses on code generators with
improved project structure, first class umbrella project support, and
scaffolding that re-enforces Phoenix as a web-interface to your
greater Elixir application. We have also included a new
`action_fallback` feature in `Phoenix.Controller` that allows you to
translate common datastructures in your domain to valid responses. In
practice, this cleans up your controller code and gives you a single
place to handle otherwise duplicated code-paths. It is [particularly
nice for JSON API controllers](https://swanros.com/2017/03/03/phoenix-1-3-is-pure-love-for-api-development/).
Also making it into the 1.3 release is a V2 of our channel wire protocol that resolves race
conditions under certain messaging patterns as well as an improved
serialization format.

For those interested in a detailed overview of the changes and design
decisions, check out my LonestarElixir keynote:
https://www.youtube.com/watch?v=tMO28ar0lW8. Note that the directory
structure in the talk is slightly outdated but all ideas still apply.

To use the new `phx.new` project generator, you can install the
archive with the following command:

    $ mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez

1.3.0 uses the `phx.` prefix on all generators. The old generators
are still around though to give the community and learning resources
time to catch up. They will be removed on 1.4.0.

As always, we have [an upgrade guide](http://phoenixframework.org/blog/upgrading-from-120-to-130)
with detailed instructions for migrating from 1.2.x projects.

1.3.0 is a backwards compatible release, so upgrading can be as easy
as bumping your `:phoenix` dep in mix.exs to "~> 1.3". For those wanting
to adopt the new conventions, the upgrade guides will take you
step-by-step. Before you upgrade, it's worth watching the keynote or
exploring the design decisions outlined below.

## Phoenix 1.3 – Design With Intent

The new project and code generators take the lessons learned from the
last two years and push folks towards better design decisions as
they're learning. New projects have a `lib/my_app` directory for
business logic and a `lib/my_app_web` directory that holds all Phoenix
related web modules, which are the web interface into your greater
Elixir application. Along with new project structure, comes new
`phx.gen.html` and `phx.html.json` generators that adopt these
goals of isolating your web interface from your domain.

### Contexts

When you generate a HTML or JSON resource with `phx.gen.html|json`,
Phoenix will generate code inside a *Context*. Contexts are dedicated
modules that expose and group related functionality. For example,
anytime you call Elixir’s standard library, be it `Logger.info/1` or
`Stream.map/2`, you are accessing different contexts. Internally,
Elixir’s logger is made of multiple modules, such as `Logger.Config`
and `Logger.Backends`, but we never interact with those modules
directly. We call the `Logger` module the context, exactly because it
exposes and groups all of the logging functionality.

For example, to generate a "user" resource we'd run:

    $ mix phx.gen.html Accounts User users email:string:unique

Notice how "Accounts" is a new required first parameter. This is the
context module where your code will live that carries out the business
logic of user accounts in your application. It could include features
like authentication and user registration. Here's a peek at part of
the code that's generated:


    # lib/my_app_web/controllers/user_controller.ex
    defmodule MyAppWeb.UserController do
      ...
      alias MyApp.Accounts

      def index(conn, _params) do
        users = Accounts.list_users()
        render(conn, "index.html", users: users)
      end

      def create(conn, %{"user" => user_params}) do
        case Accounts.create_user(user_params) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "user created successfully.")
            |> redirect(to: user_path(conn, :show, user))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      end
      ...
    end


    # lib/my_app/accounts/accounts.ex
    defmodule MyApp.Accounts do
      alias MyApp.Accounts.User

      def list_users do
        Repo.all(User)
      end

      def create_user(attrs \\ %{}) do
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()
      end
      ...
    end


You will also have an Ecto schema generated inside
`lib/my_app/accounts/user.ex`. Notice how our controller calls into an
API boundary to create or fetch users in the system. Now we can easily
reuse that logic in other controllers, in Phoenix channels, in
administrative tasks, etc. Testing also becomes more straight-forward,
as we can test the ins and outs of domain without going through the
web stack.

Designing with contexts gives you a solid foundation to grow your
application from. Using discrete, well-defined APIs that expose the
intent of your system allows you to write more maintainable
applications with reusable code. Additionally, we can get a glimpse of
what the application does and its feature-set just be exploring the
application directory structure:

    lib
    ├── my_app
    │   ├── acccounts
    │   │   ├── accounts.ex
    │   │   └── user.ex
    │   ├── sales
    │   │   ├── manager.ex
    │   │   ├── sales.ex
    │   │   └── ticket.ex
    │   └── repo.ex
    ├── my_app.ex
    ├── my_app_web
    │   ├── channels
    │   ├── controllers
    │   ├── templates
    │   └── views
    └── my_app_web.ex


With just a glance at the directory structure, we can see this
application has a user Accounts system, as well as sales system. We
can also infer that there is a natural API between these systems thru
the `sales.ex` and `accounts.ex` modules. We gain this insight
*without seeing a single line of code*. Contrast that to the previous
`web/models`, which did not reveal any relationship between files, and
mostly reflected your database structure, providing no insight on how
they actually related to your domain.


## `action_fallback`

The new `action_fallback` feature allows you to specify a plug that is
called if your controller action fails to return a valid `Plug.Conn{}`
struct. The action fallback plug's job is then to take the connection
before the controller action, as well as the result and convert it to
a valid plug response. This is particularly nice for JSON APIs as it
removes duplication across controllers. For example, your previous
controllers probably looked something like this:


```elixir

def MyAppWeb.PageController do
  alias MyApp.CMS
  def show(conn, %{"id" => id}) do
    case CMS.get_page(id, conn.assigns.current_user) do
      {:ok, page} -> render(conn, "show.html", page: page)
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render(MyAppWeb.ErrorView, :"404")
      {:error, :unauthorized} ->
        conn
        |> put_status(401)
        |> render(MyAppWeb.ErrorView, :"401")
    end
  end
end
```

This code on its own is fine, but the issue is common data-structures
in our domain, such as `{:error, :not_found}`, and `{:error,
:unauthorized}` must be handled repeatedly across many different
controllers. Now there's a better way with action fallback. With 1.3,
we can write:


```elixir
def MyAppWeb.PageController do
  alias MyApp.CMS

  action_fallback MyAppWeb.FallbackController

  def show(conn, %{"id" => id}) do
    with {:ok, page} <- CMS.get_page(id, conn.assigns.current_user) do
      render(conn, "show.html", page: page)
    end
  end
end


defmodule MyAppWeb.FallbackController do
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(MyAppWeb.ErrorView, :"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> render(MyAppWeb.ErrorView, :"401")
  end
end
```

Notice how our controller can now match on the happy path using a
`with` expression. We can then specify a fallback controller that
handles the response conversion in a single place. This is a huge win
for code clarity and removing duplication.


We are excited about these changes and their long-term payoff in
maintainability. We also feel they'll lead to sharable, isolated
libraries that the whole community can take advantage of – inside and
outside of Phoenix related projects.

If you have issues upgrading, please find us on #elixir-lang irc or
slack and we'll get things sorted out!

Last but not least, I would like to take a moment to thank the companies that
make this project possible. Much love to [plataformatec](http://plataformatec.com.br) for their
continued support of Elixir development and to [DockYard](https://dockyard.com) for their sponsorship of Phoenix.


Happy coding! 🐥🔥

-Chris


Full changelog:

## 1.3.0-rc.3 (2017-07-24)

* Enhancements
  * [ChannelTest] Subscribe `connect` to `UserSocket.id` to support
testing forceful disconnects
  * [Socket] Support static `:assigns` when defining channel routes
  * [Channel] Add V2 of wire channel wire protocol with resolved race
conditions and compacted payloads
  * [phx.new] Use new `lib/my_app` and `lib/my_app_web` directory
structure
  * [phx.new] Use new `MyAppWeb` alias convention for web modules
  * [phx.gen.context] No longer prefix Ecto table name by context name

* JavaScript client enhancements
  * Use V2 channel wire protocol support

* JavaScript client bug fixes
  * Resolve race conditions when join timeouts occur on client, while
server channel successfully joins


## 1.3.0-rc.2 (2017-05-15)

See
these [`1.2.x` to `1.3.x` upgrade instructions](https://gist.github.com/chrismccord/71ab10d433c98b714b75c886eff17357)
to bring your existing apps up to speed.

* Enhancements
  * [Generator] Add new `phx.new`, `phx.new.web`, `phx.new.ecto`
project generators with improved application structure and support for
umbrella applications
  * [Generator] Add new `phx.gen.html` and `phx.gen.json` resource
generators with improved isolation of API boundaries
  * [Controller] Add `current_path` and `current_url` to generate a
connection's path and url
  * [Controller] Introduce `action_fallback` to registers a plug to
call as a fallback to the controller action
  * [Controller] Wrap exceptions at controller to maintain connection
state
  * [Channel] Add ability to configure channel event logging with
`:log_join` and `:log_handle_in` options
  * [Channel] Warn on unhandled `handle_info/2` messages
  * [Channel] Channels now distinguish from graceful exits and
application restarts, allowing clients to enter error mode and
reconnected after cold deploys.
  * [Router] Document `match` support for matching on any HTTP method
with the special `:*` argument
  * [Router] Populate `conn.path_params` with path parameters for the
route
  * [ConnTest] Add `redirected_params/1` to return the named params
matched in the router for the redirected URL
  * [Digester] Add `mix phx.digest.clean` to remove old versions of
compiled assets
  * [phx.new] Add Erlang 20 support in `phx.new` installer archive

* Bug Fixes
  * [Controller] Harden local redirect against arbitrary URL
redirection
  * [Controller] Fix issue causing flash session to remain when using
`clear_flash/1`

* Deprecations
  * [Generator] All `phoenix.*` mix tasks have been deprecated in
favor of new `phx.*` tasks

* JavaScript client enhancements
  * Add ability to pass `encode` and `decode` functions to socket
constructor for custom encoding and decoding of outgoing and incoming
messages.
  * Detect heartbeat timeouts on client to handle ungraceful
connection loss for faster socket error detection
  * Add support for AMD/RequireJS
