defmodule SimpleServer.RequestHandler do

  require Logger

  def process_request(conn) do
    Logger.warn("REQUEST:=> #{inspect(conn)}")
    # route request to endpoint by action and path
    response = build_respponse({200, "OK", "{}"})
    {:ok, response}
  end

  # TODO this should be in a different module
  defp build_respponse({code, message, body}) do
    length = byte_size(body) + 1
    """
    HTTP/1.1 #{code} #{message}\r
    Content-Type: application/json\r
    Content-Length: #{length}\r
    Date: #{DateTime.utc_now() |> DateTime.to_iso8601()}\r
    Access-Control-Allow-Origin: *\r
    Access-Control-Allow-Credentials: true\r
    \r\n#{body}
    """ |> IO.inspect(label: "response")
  end
end
