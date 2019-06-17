defmodule SimpleServer.RequestHandler do
  alias SimpleServer.{MimeType, ResponseBuilder, Static}
  alias FileService.Document

  require Logger

  def process_request(%{action: action, path: path} = conn) do
    Logger.warn("REQUEST:=> #{inspect(conn)}")
    route(path, action, conn)
  end

  defp route('/hello_world', :GET, conn) do
    {:ok, response} = Static.hello_world()
    {:ok, ResponseBuilder.build({200, "OK", MimeType.text, response})}
  end

  defp route('/documents' ++ doc_slug, :POST, conn) do
    {:ok, response} = Document.store(conn.body, conn.content_type, doc_slug)
    {:ok, ResponseBuilder.build({201, "Created", MimeType.text, response})}
  end

  defp route('/post', :POST, conn) do
    response = "{}"
    {:ok, ResponseBuilder.build({201, "Created", MimeType.json, response})}
  end

  defp route(path, action, conn) do
    Logger.warn("404 :: Route for #{path} : #{action} called")
    {:ok, ResponseBuilder.build({404, "NOT FOUND", MimeType.json, ""})}
  end
end
