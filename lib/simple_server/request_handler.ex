defmodule SimpleServer.RequestHandler do
  alias SimpleServer.Static
  alias SimpleServer.MimeType
  alias FileService.Document

  require Logger

  def process_request(%{action: action, path: path} = conn) do
    Logger.warn("REQUEST:=> #{inspect(conn)}")
    route(path, action, conn)
  end

  defp route('/hello_world', :GET, conn) do
    {:ok, response} = Static.hello_world()
    {:ok, build_respponse({200, "OK", MimeType.text, response})}
  end

  defp route('/documents' ++ doc_slug, :POST, conn) do
    {:ok, response} = Document.store(conn.data, conn.content_type, doc_slug)
    {:ok, build_respponse({201, "Created", MimeType.text, response})}
  end

  defp route('/post', :POST, conn) do
    response = "{}"
    {:ok, build_respponse({201, "Created", MimeType.json, response})}
  end

  defp route(path, action, conn) do
    Logger.warn("404 :: Route for #{path} : #{action} called")
    {:ok, build_respponse({404, "NOT FOUND", MimeType.json, ""})}
  end

  # TODO this should be in a different module
  defp build_respponse({code, message, content_type, body}) do
    length = byte_size(body) + 1
    """
    HTTP/1.1 #{code} #{message}\r
    Content-Type: #{content_type}\r
    Content-Length: #{length}\r
    Date: #{DateTime.utc_now() |> DateTime.to_iso8601()}\r
    Access-Control-Allow-Origin: *\r
    Access-Control-Allow-Credentials: true\r
    \r\n#{body}
    """ |> IO.inspect(label: "response")
  end
end
