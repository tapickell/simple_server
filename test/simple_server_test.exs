defmodule SimpleServerTest do
  use ExUnit.Case, async: false

  alias SimpleServer.MimeType

  defmodule ServerClient do
    use Tesla

    alias SimpleServer.MimeType

    plug Tesla.Middleware.BaseUrl, "http://localhost:4040"

    def hello_world() do
      get("/hello_world")
    end

    def post(data) do
      post("/post", data, headers: [{MimeType.content, MimeType.json}])
    end

    def document_create(:jpeg, slug, data) do
      post("/documents/" <> slug, data, headers: [{MimeType.content, MimeType.jpeg}])
    end
  end

  @moduletag :capture_log

  @test_json '{\"data\": \"Hello World\"}'


  test "GET /hello_world request" do
    {:ok, response} = ServerClient.hello_world()
    assert response.status == 200
    assert response.body == "Hello World!\n"
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.text}
  end

  test "JSON POST request with data" do
    {:ok, response} = ServerClient.post(@test_json)
    assert response.status == 201
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.json}
  end

  test "POST documents request with doc" do
    file = "static/You_Must_Be_New.jpg"
    slug = "you-must-be-new"
    {:ok, response} = ServerClient.document_create(:jpeg, slug, file)
    assert response.status == 201
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.json}
  end
end
