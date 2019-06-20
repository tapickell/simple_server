defmodule FileService.Document do
  @moduledoc """
    # FileService.Document
    This is a wrapper around the idea of a Document in the domain.
    It acts kind of like a controller but on the context side with no knowledge
    of the web layer.

  * These are some initial thoughts I had after the first run at this. I was questioning my approach with this light wrapper, a style I used more in Ruby and NodeJS. I was thinking this felt like a model which seemed wrong in a functional context, that the model should be pure data, a struct, and that functions perform on that data structure.

    ## Initial Thoughts
    Should this layer be here??
    or should Document be a struct that represents
    the document datatype?
    {key, type, data}
    and Store can store Documents

    ## Testing
    I tested just having Document be a struct and
    calling store from the request handler
    since the request handler is like a router it seemed to reach
    a little deeper than I liked and the Document layer seem like a controller
    of sorts but with less knowledge of the http layer going on since it only knows about the layer
    below it to store and retrieve documents and how to structure error messages
    it has no clue that the calling code takes those errors and then constructs them with
    an appropriate error code for web purposes.
    that request handler could be swapped out for a cli request handler instead and
    I don't think that document or store would change one bit.

    ## After Thoughts
    Creating a struct like %Document{} did not seem necessary after testing as I would
    create a document struct in the request handler, than pass it to Store.insert.
    This gives part of the web layer, the web request handler, knowledge of the underlying data
    structure needed to store this information.
    The only other place was in the returning of a match from the Store in the lookup
    function. A match was returned than a %Document struct created to return a Document
    to the request handler. The %Documents are not created in 2 different places.
    And know the web layer not only needs to know how to create a %Document, but also how to decode
    a %Document to get its data to return in the web response
    This felt strange. Maybe mainly because I am not storing the data as a struct in :ETS,
    but as a tuple {key, type, data}.
    So creating this superfluous %Document struct/model seemed a little extra.
  """

  alias FileService.Store

  require Logger

  def store(file_key, file_type, data) do
    case Store.insert(file_key, file_type, data) do
      :ok ->
        {:ok, file_key}
      :error ->
        msg = "File #{file_key} was not able to be stored"
        Logger.error(msg)
        {:error, msg}
    end
  end

  def fetch(file_key) do
    case Store.lookup(file_key) do
      {:ok, file_store} ->
        {:ok, file_store}
      {:error, error} ->
        msg = "File was unable to be retrieved due to error: #{inspect(error)}"
        Logger.error(msg)
        {:error, msg}
    end
  end

  def remove(file_key) do
    case Store.delete(file_key) do
      :ok ->
        {:ok, file_key}
      :error ->
        msg = "File #{file_key} was not able to be removed"
        Logger.error(msg)
        {:error, msg}
    end
  end
end
