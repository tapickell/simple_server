defmodule SimpleServerTest do
  use ExUnit.Case, async: false

  alias SimpleServer.MimeType
  alias SimpleServer.ServerClient

  # @moduletag :capture_log

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
    file = "test/static/You_Must_Be_New.jpg"
    slug = "you-must-be-new"
    {:ok, file_data} = File.read(file)
    {:ok, response} = ServerClient.document_create(:jpeg, slug, file_data)
    assert response.status == 201
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.json}
  end
end
