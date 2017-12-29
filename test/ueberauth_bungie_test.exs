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
end
