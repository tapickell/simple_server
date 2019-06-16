defmodule SimpleServerTest do
  use ExUnit.Case, async: false
  # doctest SimpleServer

  @moduletag :capture_log

  @test_url 'http://localhost:4040'

  @c_type 'content-type'
  @json_type 'application/json'
  @text_type 'text/plain'

  @test_json '{\"data\": \"Hello World\"}'


  setup_all do
    {:ok, [:inets]} = Application.ensure_all_started(:inets)
    :ok
  end

  setup do
    Application.stop(:simple_server)
    :ok = Application.start(:simple_server)
  end

  test "GET /hello_world request" do
    uri = @test_url ++ '/helloworld'
    {:ok, result} = :httpc.request(uri)
    assert result == []
  end

  # test "JSON POST request with data" do
  #   uri = @test_url ++ '/post'
  #   {:ok, {{_v, code, _p}, resp_h, body}} = :httpc.request(:post, {uri, [], @json_type, @test_json}, [], [])
  #   assert code == 404
  #   assert List.keyfind(resp_h, @c_type, 0) == {@c_type, @json_type}
  #   assert body == []
  # end

end
