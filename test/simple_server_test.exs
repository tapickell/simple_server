defmodule SimpleServerTest do
  use ExUnit.Case, async: false

  alias SimpleServer.MimeType
  alias SimpleServer.ServerClient

  @moduletag :capture_log

  test "GET /hello_world request" do
    {:ok, response} = ServerClient.hello_world()
    assert response.status == 200
    assert response.body == "Hello World!\n"
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.text}
  end

  test "POST documents request with doc" do
    file = "test/static/You_Must_Be_New.jpg"
    slug = "you-must-be-new"
    {:ok, file_data} = File.read(file)
    {:ok, response} = ServerClient.document_create(:jpeg, slug, file_data)
    assert response.status == 201
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.json}
    {:ok, response} = ServerClient.document_delete(slug)
    assert response.status == 200
  end

  test "GET documents by slug request" do
    file = "test/static/You_Must_Be_New.jpg"
    slug = "you-must-be-new"
    {:ok, file_data} = File.read(file)
    {:ok, response1} = ServerClient.document_create(:jpeg, slug, file_data)
    assert response1.status == 201
    {:ok, response} = ServerClient.document_get(slug)
    assert response.status == 200
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.jpeg}
    # assert response.body == "{\"id\": \"#{slug}\", \"data\": \"#{file_data}\"}"
    {:ok, response} = ServerClient.document_delete(slug)
    assert response.status == 200
  end

  test "GET documents by slug request returns 404 when file doesn't exist" do
    slug = "you-must-be-new"
    {:ok, response} = ServerClient.document_get(slug)
    assert response.status == 404
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.json}
    assert response.body =="{\"error\": \"File was unable to be retrieved due to error: :no_match\"}\n"
  end

  test "DELETE documents request with slug" do
    file = "test/static/You_Must_Be_New.jpg"
    slug = "you-must-be-new"
    {:ok, file_data} = File.read(file)
    {:ok, response} = ServerClient.document_create(:jpeg, slug, file_data)
    assert response.status == 201
    {:ok, response} = ServerClient.document_delete(slug)
    assert response.status == 200
    assert List.keyfind(response.headers, MimeType.content, 0) ==  {MimeType.content, MimeType.json}
    assert response.body == "{\"id\": \"you-must-be-new\"}\n"
  end

end
