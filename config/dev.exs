use Mix.Config

config :oauth2, debug: true

config :ueberauth, Ueberauth,
  providers: [
    bungie: {Ueberauth.Strategy.Bungie, []}
  ]

import_config "dev.secret.exs"
