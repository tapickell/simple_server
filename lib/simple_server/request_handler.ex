defmodule SimpleServer.RequestHandler do
  alias SimpleServer.{MimeType, ResponseBuilder, Static}
  alias FileService.Document

  require Logger

  @created "Created"
  @empty_obj "{}"
  @notfound "NOT FOUND"
  @ok "OK"
  @unpentity "Unprocessable Entity"

  def process_request(%{action: action, path: path} = conn) do
    Logger.warn("REQUEST:=> #{inspect(conn)}")
    route(path, action, conn)
  end

  defp route('/hello_world', :GET, conn) do
    {:ok, response} = Static.hello_world()
    {:ok, ResponseBuilder.build({200, @ok, MimeType.text, response})}
  end

  defp route('/documents' ++ doc_slug, :POST, conn) do
    case Document.store(doc_slug, conn.content_type, conn.body) do
      {:ok, response} ->
        {:ok, ResponseBuilder.build({201, @created, MimeType.json, response})}
      {:error, msg} ->
        {:ok, ResponseBuilder.build({422, @unpentity, MimeType.json, "{\"error\": \"#{msg}\"}"})}
    end
  end

  defp route('/post', :POST, conn) do
    response = "{}"
    {:ok, ResponseBuilder.build({201, @created, MimeType.json, response})}
  end

  defp route(path, action, conn) do
    Logger.warn("404 :: Route for #{path} : #{action} called")
    {:ok, ResponseBuilder.build({404, @notfound, MimeType.json, @empty_obj})}
  end
end
