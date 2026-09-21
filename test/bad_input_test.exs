defmodule Url.BadInputTest do
  use ExUnit.Case

  # Library code must return an error tuple (or a sensible empty
  # result) on any input, however malformed. None of these may raise.

  describe "empty scheme-specific paths" do
    test "mailto: with no address parses to an empty recipient list" do
      assert {:ok, %URL{parsed_path: %URL.Mailto{to: [], params: %{}}}} = URL.new("mailto:")
    end

    test "mailto: with only header fields parses" do
      assert {:ok, %URL{parsed_path: %URL.Mailto{to: [], params: %{"subject" => "x"}}}} =
               URL.new("mailto:?subject=x")
    end

    test "mailto:? with an empty query parses" do
      assert {:ok, %URL{parsed_path: %URL.Mailto{to: [], params: %{}}}} = URL.new("mailto:?")
    end

    test "geo: returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("geo:")
    end

    test "tel: returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("tel:")
    end

    test "uuid: returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("uuid:")
    end

    test "urn: returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("urn:")
    end

    test "urn:uuid: returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("urn:uuid:")
    end

    test "urn with an unknown namespace parses with no parsed path" do
      assert {:ok, %URL{parsed_path: nil}} = URL.new("urn:isbn:123")
    end

    test "data: with no payload parses to empty data" do
      assert {:ok, %URL{parsed_path: %URL.Data{data: ""}}} = URL.new("data:")
    end
  end

  describe "malformed scheme-specific paths" do
    test "geo with a missing coordinate returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("geo:1")
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("geo:;u=1")
    end

    test "geo with a malformed parameter returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("geo:1,2;=x")
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("geo:1,2;u")
    end

    test "tel with no digits returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("tel:abc")
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("tel:;phone-context=+61")
    end

    test "tel with a malformed parameter returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("tel:+61-0407-555-987;ext=")
    end

    test "uuid that is not a UUID returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("uuid:not-a-uuid")
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("uuid:;a=b")
    end

    test "data with an invalid percent triplet returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("data:,%ZZ")
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("data:,%")
    end

    test "data with a missing comma returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("data:;base64")
    end

    test "data with invalid base64 keeps the raw payload as an error" do
      assert {:ok, %URL{parsed_path: %URL.Data{data: {:error, "!!!"}}}} =
               URL.new("data:;base64,!!!")
    end

    test "mailto with a malformed header field returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("mailto:a@b.com?%ZZ=1")
      assert {:error, {URL.Parser.ParseError, _}} = URL.new("mailto:a@b.com?subject")
    end
  end

  describe "syntactically invalid URLs" do
    test "spaces and reserved characters return a URI.Error" do
      assert {:error, {URI.Error, _}} = URL.new(" ")
      assert {:error, {URI.Error, _}} = URL.new("data:text/plain,a b")
      assert {:error, {URI.Error, _}} = URL.new("/path/>")
      assert {:error, {URI.Error, _}} = URL.new("http://[::1")
    end

    test "an empty string parses with no scheme" do
      assert {:ok, %URL{scheme: nil, parsed_path: nil}} = URL.new("")
    end

    test "very long input is handled" do
      assert {:ok, %URL{}} = URL.new(String.duplicate("a", 100_000))

      assert {:ok, %URL{parsed_path: %URL.Data{}}} =
               URL.new("data:," <> String.duplicate("%41", 10_000))
    end
  end

  describe "wrong-type input" do
    test "URL.new/1 returns an ArgumentError tuple" do
      for input <- [nil, 1, :atom, :"", %{}, [], {:ok, "x"}] do
        assert {:error, {ArgumentError, _}} = URL.new(input)
      end
    end

    test "URL.new!/1 raises ArgumentError" do
      assert_raise ArgumentError, fn -> URL.new!(nil) end
    end
  end

  describe "URL.parse_query_string/1" do
    test "a URL without a query yields an empty map" do
      assert URL.parse_query_string(URL.new!("geo:1,2")) == %{}
      assert URL.parse_query_string(%{query: nil}) == %{}
      assert URL.parse_query_string(nil) == %{}
    end

    test "an empty query string yields an empty map" do
      assert URL.parse_query_string("") == %{}
    end

    test "a malformed query returns an error" do
      assert {:error, {URL.Parser.ParseError, _}} = URL.parse_query_string("a=%ZZ")
      assert {:error, {URL.Parser.ParseError, _}} = URL.parse_query_string("a")
    end

    test "an error tuple is passed through" do
      error = {:error, {URI.Error, "boom"}}
      assert URL.parse_query_string(error) == error
      assert {:error, {URI.Error, _}} = URL.new(" ") |> URL.parse_query_string()
    end

    test "wrong-type input returns an ArgumentError tuple" do
      for input <- [1, :atom, [], {:ok, "x"}] do
        assert {:error, {ArgumentError, _}} = URL.parse_query_string(input)
      end
    end
  end

  describe "tel numbers ExPhoneNumber cannot parse" do
    test "keep the raw number rather than an error tuple" do
      assert {:ok, %URL{parsed_path: %URL.Tel{tel: "+1"}}} = URL.new("tel:+1")

      long = String.duplicate("1", 5000)
      assert {:ok, %URL{parsed_path: %URL.Tel{tel: ^long}}} = URL.new("tel:" <> long)
    end
  end

  describe "ex_cldr without a default backend" do
    test "tel parsing falls back to the other territory sources" do
      backend = Application.get_env(:ex_cldr, :default_backend)
      Application.delete_env(:ex_cldr, :default_backend)

      try do
        assert {:ok, %URL{parsed_path: %URL.Tel{tel: "+61 407 555 987"}}} =
                 URL.new("tel:0407-555-987;phone-context=+61")
      after
        Application.put_env(:ex_cldr, :default_backend, backend)
      end
    end
  end
end
