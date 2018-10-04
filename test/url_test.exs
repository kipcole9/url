defmodule UrlTest do
  use ExUnit.Case
  doctest Url

  test "greets the world" do
    assert Url.hello() == :world
  end
end
