defmodule URL.Http do
  def parse(%URI{scheme: "http"} = uri) do
    uri
  end
end