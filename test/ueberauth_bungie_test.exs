defmodule UeberauthBungieTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest UeberauthBungie

  describe "handle_callback!" do
    test "with no code" do
      conn = %Plug.Conn{}
      result = Ueberauth.Strategy.Bungie.handle_callback!(conn)
      failure = result.assigns.ueberauth_failure
      assert length(failure.errors) == 1
      [no_code_error] = failure.errors

      assert no_code_error.message_key == "missing_code"
      assert no_code_error.message == "No code received"
    end
  end

  describe "credentials/1" do
    test "returns the correct struct" do
      now = DateTime.to_iso8601(DateTime.utc_now())

      token = %{
        access_token: "12345",
        refresh_token: "45678",
        expires_at: now,
        token_type: "refresh"
      }

      conn = %Plug.Conn{}
      conn = Plug.Conn.put_private(conn, :bungie_token, token)

      credentials = Ueberauth.Strategy.Bungie.credentials(conn)

      assert(credentials.token == token.access_token)
      assert(credentials.refresh_token == token.refresh_token)
      assert(credentials.expires_at == now)
      assert(credentials.token_type == token.token_type)
      assert(credentials.expires == true)
      assert(credentials.scopes == nil)
    end
  end
end
