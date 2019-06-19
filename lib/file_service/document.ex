defmodule FileService.Document do
  alias FileService.Store

  require Logger

  def store(file_slug, content_type, data) do
    case Store.insert(file_slug, content_type, data) do
      :ok ->
        {:ok, file_slug}
      :error ->
        msg = "File #{file_slug} was not able to be stored"
        Logger.error(msg)
        {:error, msg}
    end
  end

  def fetch(file_slug) do
    case Store.lookup(file_slug) do
      {:ok, file_store} ->
        {:ok, file_store}
      {:error, error} ->
        msg = "File was unable to be retrieved due to error: #{inspect(error)}"
        Logger.error(msg)
        {:error, msg}
    end
  end

  def remove(file_slug) do
    case Store.delete(file_slug) do
      :ok ->
        {:ok, file_slug}
      :error ->
        msg = "File #{file_slug} was not able to be removed"
        Logger.error(msg)
        {:error, msg}
    end
  end
end

# Should this layer be here??
# or should Document be a struct that represents
# the document datatype?
# {slug, type, data}
# and Store can store Documents
