defmodule SimpleServer.ResponseBuilder do

  def build({code, message, content_type, body}) do
    length = body_length(body)
    """
    HTTP/1.1 #{code} #{message}\r
    Content-Type: #{content_type}\r
    Content-Length: #{length}\r
    Date: #{DateTime.utc_now() |> DateTime.to_iso8601()}\r
    Access-Control-Allow-Origin: *\r
    Access-Control-Allow-Credentials: true\r
    \r\n#{body}
    """
  end

  defp body_length(n) when is_list(n), do: List.to_string(n) |> body_length
  defp body_length(n) when is_binary(n), do: byte_size(n) + 1
end
