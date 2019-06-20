defmodule SimpleServer.ServerClient do
  use Tesla

  alias SimpleServer.MimeType

  plug Tesla.Middleware.BaseUrl, "http://localhost:4040"
  plug Tesla.Middleware.Logger

  def hello_world() do
    get("/hello_world")
  end

  def post(data) do
    post("/post", data, headers: [{MimeType.content, MimeType.json}])
  end

  def document_create(:jpeg, slug, data) do
    post("/documents/" <> slug, data, headers: [{MimeType.content, MimeType.jpeg}])
  end

  def document_get(slug) do
    get("/documents/" <> slug)
  end

  def document_delete(slug) do
    delete("/documents/" <> slug)
  end
end
