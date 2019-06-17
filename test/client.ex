defmodule SimpleServer.ServerClient do
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
