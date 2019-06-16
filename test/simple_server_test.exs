defmodule SimpleServerTest do
  use ExUnit.Case, async: false
  # doctest SimpleServer

  @moduletag :capture_log

  @test_json '{\"data\": \"Hello World\"}'
  @c_type "content-type"
  @json_type "application/json"

  defmodule TestServer do
    use Tesla
    plug Tesla.Middleware.BaseUrl, "http://localhost:4040"

    def hello_world() do
      get("/helloworld")
    end

    def post(data) do
      post("/post", data, headers: [{@c_type, @json_type}])
    end
  end

  setup do
    Application.stop(:simple_server)
    :ok = Application.start(:simple_server)
  end

  # test "GET /hello_world request" do
  #   {:ok, response} = TestServer.hello_world()
  #   assert response == []
  # end

  test "JSON POST request with data" do
    {:ok, response} = TestServer.post(@test_json)
    assert response.status == 404
    assert List.keyfind(response.headers, @c_type, 0) == {@c_type, @json_type}
    assert response.body == []
  end
end
