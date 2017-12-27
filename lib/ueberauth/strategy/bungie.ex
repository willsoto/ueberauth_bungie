defmodule Ueberauth.Strategy.Bungie do
  @moduledoc """
  Bungie Strategy for Ueberauth
  """
  use Ueberauth.Strategy, scope: ""

  alias Ueberauth.Strategy.Bungie
  alias Ueberauth.Auth.{Info,Credentials,Extra}

  def handle_request!(conn) do
    opts = []
    
    redirect!(conn, Bungie.OAuth.authorize_url!(opts))
  end

  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    params = [code: code]
    opts = [redirect_uri: callback_url(conn)]

    case Bungie.OAuth.get_access_token(params, opts) do
      {:ok, token} ->
        fetch_user(conn, token)
      {:error, {error_code, error_description}} ->
        set_errors!(conn, [error(error_code, error_description)])      
    end
  end

  def credentials(conn) do
    %Credentials{}
  end

  def info(conn) do
    %Info{}
  end

  def extra(conn) do
    %Extra{}
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :bungie_token, token)

    # @todo Figure out if this is the right endpoint
    path = "https://www.bungie.net/platform/app/oauth/token/"
    resp = Ueberauth.Strategy.Bungie.OAuth.get(token, path)

    case resp do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])
      {:ok, %OAuth2.Response{status_code: status_code, body: user}} when status_code in 200..399 ->
        put_private(conn, :google_user, user)
      {:error, %OAuth2.Response{status_code: status_code}} ->
        set_errors!(conn, [error("OAuth2", status_code)])
      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp with_param(opts, key, conn) do
    if value = conn.params[to_string(key)], do: Keyword.put(opts, key, value), else: opts
  end

  defp with_optional(opts, key, conn) do
    if option(conn, key), do: Keyword.put(opts, key, option(conn, key)), else: opts
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end