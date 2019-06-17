defmodule SimpleServer.RequestHandler do

  defmodule SimpleServer.Static do
    def hello_world(), do: {:ok, "Hello World!"}
  end
  alias SimpleServer.Static
  alias FileService.Document


  require Logger

  @text_type "text/plain"
  @json_type "application/json"

  def process_request(%{action: action, path: path} = conn) do
    Logger.warn("REQUEST:=> #{inspect(conn)}")
    route(path, action, conn)
  end

  defp route('/hello_world', :GET, conn) do
    {:ok, response} = Static.hello_world()
    {:ok, build_respponse({200, "OK", @text_type, response})}
  end

  defp route('/documents', :POST, conn) do
    {:ok, response} = Document.store(conn.data)
    {:ok, build_respponse({201, "Created", @text_type, response})}
  end

  defp route(path, action, conn) do
    Logger.warn("404 :: Route for #{path} : #{action} called")
    {:ok, build_respponse({404, "NOT FOUND", @json_type, ""})}
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
