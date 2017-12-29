# Überauth Bungie

[![Hex Version](https://img.shields.io/hexpm/v/ueberauth_bungie.svg)](https://hex.pm/packages/ueberauth_bungie)
[![CircleCI](https://circleci.com/gh/willsoto/ueberauth_bungie/tree/master.svg?style=svg&circle-token=1121656241eba82bacba9901e3e4086bc588dd2d)](https://circleci.com/gh/willsoto/ueberauth_bungie/tree/master)

> Bungie Oauth2 strategy for Überauth.

## Installation

1. [Setup your application](https://www.bungie.net/en/Application)
2. Add `:ueberauth_bungie` to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:ueberauth_bungie, "~> 0.1.0"}
  ]
end
```

3. Add Bungie to your Überauth configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    bungie: {Ueberauth.Strategy.Bungie, []}
  ]
```

4. Update your provider configuration:

```elixir
config :ueberauth, Ueberauth.Strategy.Bungie.OAuth,
  client_id: System.get_env("BUNGIE_CLIENT_ID"),
  redirect_uri: System.get_env("BUNGIE_OAUTH_REDIRECT_URI"),
  api_key: System.get_env("BUNGIE_API_KEY")
```

5. Include the Überauth plug in your controller:

```elixir
defmodule MyAppWeb.AuthController do
  use MyAppWeb, :controller

  plug(Ueberauth)

  # ...
end
```

6. Create the request and callback routes if you haven't already:

```elixir
  scope "/auth", MyAppWeb do
    pipe_through(:browser)

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
  end
```

7. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses. Check out the [example app](https://github.com/ueberauth/ueberauth_example) for more information.

## Documentation

Docs can be found at [https://hexdocs.pm/ueberauth_bungie](https://hexdocs.pm/ueberauth_bungie).
