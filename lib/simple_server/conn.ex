defmodule SimpleServer.Conn do
  defstruct accept: nil,
    action: nil,
    body: nil,
    complete: false,
    content_length: nil,
    content_type: nil,
    errors: [],
    host: nil,
    path: nil,
    user_agent: nil
end
