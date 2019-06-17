defmodule FileService.Document do
  def store(file_data, content_type, file_slug) do
    # store file in memory.
    # not sure, like in a gen server?
    # or in ets?
    # or what else would be meant by in memory
    # taking that to be no DB
    {:ok, file_slug}
  end
end
