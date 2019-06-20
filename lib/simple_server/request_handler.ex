defmodule SimpleServer.RequestHandler do
  alias SimpleServer.{MimeType, ResponseBuilder, Static}
  alias FileService.Document

  require Logger

  @created "Created"
  @empty_obj "{}"
  @notfound "NOT FOUND"
  @ok "OK"
  @unpentity "Unprocessable Entity"

  # TODO - Should Mime validate type somewhere??
  def process_request(%{action: action, path: path} = conn) do
    Logger.warn("REQUEST:=> #{inspect(conn)}")
    route(path, action, conn)
  end

  defp route('/hello_world', :GET, conn) do
    {:ok, response} = Static.hello_world()
    {:ok, ResponseBuilder.build({200, @ok, MimeType.text, response})}
  end

  defp route('/documents/' ++ doc_slug, :POST, conn) do
    case Document.store(doc_slug, conn.content_type, conn.body) do
      {:ok, response} ->
        {:ok, ResponseBuilder.build({201, @created, MimeType.json, response})}
      {:error, msg} ->
        {:ok, ResponseBuilder.build({422, @unpentity, MimeType.json, error_json(msg)})}
    end
  end

  defp route('/documents/' ++ doc_slug, :GET, conn) do
    case Document.fetch(doc_slug) do
      {:ok, {key, type, data} = response} ->
        {:ok, ResponseBuilder.build({200, @ok, type, data_json(key, data)})}
      {:error, msg} ->
        {:ok, error_json(msg) |> four_o_four()}
    end
  end

  defp route('/documents/' ++ doc_slug, :DELETE, conn) do
    case Document.remove(doc_slug) do
      {:ok, key} ->
        {:ok, ResponseBuilder.build({200, @ok, MimeType.json, slug_json(key)})}
      {:error, msg} ->
        {:ok, error_json(msg) |> four_o_four()}
    end
  end

  defp route(path, action, conn) do
    msg = "404 :: Route for #{path} : #{action} called"
    Logger.warn(msg)
    {:ok, error_json(msg) |> four_o_four()}
  end

  defp four_o_four(return \\ @empty_obj) do
    ResponseBuilder.build({404, @notfound, MimeType.json, return})
  end

  # View Layer concerns with JSON
  # TODO this could live somewhere else
  defp error_json(msg) do
    "{\"error\": \"#{msg}\"}"
  end

  defp slug_json(slug) do
    "{\"id\": \"#{slug}\"}"
  end

  defp data_json(key, data) do
    "{\"id\": \"#{key}\", \"data\": \"#{data}\"}"
  end
end
