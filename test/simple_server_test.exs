defmodule SimpleServerTest do
  use ExUnit.Case, async: false

  @moduletag :capture_log

  @test_json '{\"data\": \"Hello World\"}'
  @c_type "content-type"
  @json_type "application/json"
  @text_type "text/plain"

  defmodule ServerClient do
    use Tesla
    plug Tesla.Middleware.BaseUrl, "http://localhost:4040"

    def hello_world() do
      get("/hello_world")
    end

    def post(data) do
      post("/post", data, headers: [{@c_type, @json_type}])
    end
  end

  test "GET /hello_world request" do
    {:ok, response} = ServerClient.hello_world()
    assert response.status == 200
    assert response.body == "Hello World!\n"
    assert List.keyfind(response.headers, @c_type, 0) == {@c_type, @text_type}
  end

  test "JSON POST request with data" do
    {:ok, response} = ServerClient.post(@test_json)
    assert response.status == 404
    assert List.keyfind(response.headers, @c_type, 0) == {@c_type, @json_type}
  end
end
