use Mix.Config

config :oauth2, debug: true

config :ueberauth, Ueberauth,
  providers: [
    bungie: {Ueberauth.Strategy.Bungie, []}
  ]

try do
  import_config "#{Mix.env()}.secret.exs"
rescue
  _ -> IO.puts("Secret not found for #{Mix.env()}")
end
