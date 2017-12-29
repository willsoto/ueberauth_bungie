defmodule Ueberauth.Strategy.Bungie.OAuthTest do
  require IEx
  use ExUnit.Case, async: true

  doctest Ueberauth.Strategy.Bungie.OAuth

  describe "authorize_url! via config" do
    setup [:create_authorization_url]

    test "works", context do
      assert(context.uri.scheme == "https")
      assert(context.uri.host == "www.bungie.net")
      assert(context.uri.path == "/en/oauth/authorize")
    end

    test "sets the correct query params", context do
      query = context.query

      assert(query["client_id"] == "12345")
      assert(query["redirect_uri"] == "https://localhost:4000/auth/bungie/callback")
      assert(query["response_type"] == "code")
    end
  end

  describe "authorize_url! via overriding" do
    setup do
      opts = [
        client_id: "foobar",
        redirect_uri: "https://app.destinyitemmanager/auth/bungie/callback",
        api_key: "abcdefg"
      ]

      %{opts: opts}
    end

    setup [:create_authorization_url]

    test "works", context do
      assert(context.uri.scheme == "https")
      assert(context.uri.host == "www.bungie.net")
      assert(context.uri.path == "/en/oauth/authorize")
    end

    test "sets the correct query params", context do
      query = context.query

      assert(query["client_id"] == "foobar")
      assert(query["redirect_uri"] == "https://app.destinyitemmanager/auth/bungie/callback")
      assert(query["response_type"] == "code")
    end
  end

  defp create_authorization_url(context) do
    params = Map.get(context, :params, [])
    opts = Map.get(context, :opts, [])

    authorize_url = Ueberauth.Strategy.Bungie.OAuth.authorize_url!(params, opts)
    uri = URI.parse(authorize_url)
    query = URI.decode_query(uri.query)

    %{
      authorize_url: authorize_url,
      uri: uri,
      query: query
    }
  end
end
