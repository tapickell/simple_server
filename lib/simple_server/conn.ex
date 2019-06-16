defmodule SimpleServer.Conn do
  defstruct accept: nil,
    action: nil,
    body: nil,
    content_length: nil,
    content_type: nil,
    host: nil,
    path: nil,
    user_agent: nil
end
