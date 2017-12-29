defmodule Ueberauth.Strategy.Bungie do
  @moduledoc """
  Bungie Strategy for Ueberauth
  """
  use Ueberauth.Strategy, oauth2_module: Ueberauth.Strategy.Bungie.OAuth

  alias Ueberauth.Auth.{Info, Credentials, Extra}

  def uid(conn) do
    conn.private.bungie_user["Response"]["membershipId"]
  end

  def handle_request!(conn) do
    opts =
      []
      |> Keyword.put(:redirect_uri, callback_url(conn))

    redirect!(conn, Ueberauth.Strategy.Bungie.OAuth.authorize_url!(opts))
  end

  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    params = [code: code]
    opts = [redirect_uri: callback_url(conn)]

    case Ueberauth.Strategy.Bungie.OAuth.get_access_token(params, opts) do
      {:ok, token} ->
        fetch_user(conn, token)

      {:error, {error_code, error_description}} ->
        set_errors!(conn, [error(error_code, error_description)])
    end
  end

  def credentials(conn) do
    token = conn.private.bungie_token

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
      scopes: nil
    }
  end

  def info(conn) do
    user = conn.private.bungie_user["Response"]

    %Info{
      name: user["displayName"],
      location: user["locale"]
    }
  end

  def extra(conn) do
    %Extra{
      raw_info: conn.private.bungie_user["Response"]
    }
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :bungie_token, token)

    # @todo Figure out if this is the right endpoint
    path =
      "https://www.bungie.net/Platform/User/GetBungieNetUserById/" <>
        token.other_params["membership_id"] <> "/"

    resp = Ueberauth.Strategy.Bungie.OAuth.get(token, path)

    case resp do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}} when status_code in 200..399 ->
        put_private(conn, :bungie_user, user)

      {:error, %OAuth2.Response{status_code: status_code}} ->
        set_errors!(conn, [error("OAuth2", status_code)])

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end
end
