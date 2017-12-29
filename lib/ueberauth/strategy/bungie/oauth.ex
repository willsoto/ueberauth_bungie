defmodule Ueberauth.Strategy.Bungie.OAuth do
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    client_id: System.get_env("BUNGIE_CLIENT_ID"),
    # TODO: how to generate this?
    # state: "",
    redirect_uri: System.get_env("BUNGIE_OAUTH_REDIRECT_URI"),
    site: "https://www.bungie.net/Platform",
    authorize_url: "https://www.bungie.net/en/oauth/authorize",
    token_url: "https://www.bungie.net/platform/app/oauth/token/",
    token_method: :post
  ]

  def client(opts \\ []) do
    config =
      :ueberauth
      |> Application.fetch_env!(Ueberauth.Strategy.Bungie.OAuth)
      |> check_config_key_exists(:client_id)
      |> check_config_key_exists(:api_key)
      |> check_config_key_exists(:redirect_uri)

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)
      |> Keyword.merge(headers: ["X-API-Key": config[:api_key]])

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client
    |> put_param("client_secret", client().client_secret)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_access_token(params \\ [], opts \\ []) do
    case opts |> client |> OAuth2.Client.get_token(params) do
      {:error, %{body: %{"error" => error, "error_description" => description}}} ->
        {:error, {error, description}}

      {:ok, %{token: %{access_token: nil} = token}} ->
        %{"error" => error, "error_description" => description} = token.other_params
        {:error, {error, description}}

      {:ok, %{token: token}} ->
        {:ok, token}
    end
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_secret", client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  defp check_config_key_exists(config, key) when is_list(config) do
    unless Keyword.has_key?(config, key) do
      raise "#{inspect(key)} missing from config :ueberauth, Ueberauth.Strategy.Bungie"
    end

    config
  end

  defp check_config_key_exists(_, _) do
    raise "Config :ueberauth, Ueberauth.Strategy.Bungie is not a keyword list, as expected"
  end
end
