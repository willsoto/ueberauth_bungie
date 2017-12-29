use Mix.Config

config :oauth2, debug: true

config :exvcr,
  vcr_cassette_library_dir: "fixture/vcr_cassettes",
  custom_cassette_library_dir: "fixture/custom_cassettes",
  filter_sensitive_data: [],
  filter_url_params: [],
  filter_request_headers: [],
  response_headers_blacklist: []

config :ueberauth, Ueberauth,
  providers: [
    bungie: {Ueberauth.Strategy.Bungie, []}
  ]

config :ueberauth, Ueberauth.Strategy.Bungie.OAuth,
  client_id: System.get_env("BUNGIE_CLIENT_ID") || "12345",
  redirect_uri:
    System.get_env("BUNGIE_OAUTH_REDIRECT_URI") || "https://localhost:4000/auth/bungie/callback",
  api_key: System.get_env("BUNGIE_API_KEY") || "56789"
