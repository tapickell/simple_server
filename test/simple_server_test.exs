defmodule SimpleServerTest do
  use ExUnit.Case
  # doctest SimpleServer

  @moduletag :capture_log

  @test_url 'http://localhost:4040'
  @json_type 'application/json'
  @c_type 'content-type'
  @test_json '{\"data\": \"Hello World\"}'

  setup do
    {:ok, [:inets]} = Application.ensure_all_started(:inets)
    Application.stop(:simple_server)
    :ok = Application.start(:simple_server)
  end

  test "JSON POST request with data" do
    uri = @test_url ++ '/post'
    {:ok, {{v, code, p}, resp_h, body}} = :httpc.request(:post, {uri, [], @json_type, @test_json}, [], [])
    assert code == 200
    assert List.keyfind(resp_h, @c_type, 0) == {@c_type, @json_type}
    assert body == []
  end
end
