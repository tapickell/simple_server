defmodule SimpleServer.MimeType do
  @content_type "content-type"

  @json_type "application/json"
  @text_type "text/plain"
  @jpeg_type "image/jpeg"

  def content(), do: @content_type
  def json(), do: @json_type
  def text(), do: @text_type
  def jpeg(), do: @jpeg_type
end
