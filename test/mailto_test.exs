defmodule MailtoTest do
  use ExUnit.Case

  test "simple mailto" do
    assert URL.parse("mailto:infobot@example.com?subject=current-issue") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Mailto{
          params: %{"subject" => "current-issue"},
          to: ["infobot@example.com"]
        },
        path: "infobot@example.com",
        port: nil,
        query: "subject=current-issue",
        scheme: "mailto",
        userinfo: nil
      }
  end

  test "with params" do
    assert URL.parse("mailto:infobot@example.com?body=send%20current-issue%0D%0Asend%20index") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Mailto{
          params: %{"body" => "send current-issue\r\nsend index"},
          to: ["infobot@example.com"]
        },
        path: "infobot@example.com",
        port: nil,
        query: "body=send%20current-issue%0D%0Asend%20index",
        scheme: "mailto",
        userinfo: nil
      }
  end

  test "percent decode address" do
    assert URL.parse("mailto:gorby%25kremvax@example.com") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Mailto{params: %{}, to: ["gorby%kremvax@example.com"]},
        path: "gorby%25kremvax@example.com",
        port: nil,
        query: nil,
        scheme: "mailto",
        userinfo: nil
      }
  end

  test "more complications" do
    assert URL.parse("mailto:%22not%40me%22@example.org") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Mailto{params: %{}, to: ["\"not@me\"@example.org"]},
        path: "%22not%40me%22@example.org",
        port: nil,
        query: nil,
        scheme: "mailto",
        userinfo: nil
      }

    assert URL.parse("mailto:%22oh%5C%5Cno%22@example.org") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Mailto{params: %{}, to: ["\"oh\\\\no\"@example.org"]},
        path: "%22oh%5C%5Cno%22@example.org",
        port: nil,
        query: nil,
        scheme: "mailto",
        userinfo: nil
      }
  end

  test "simple utf8 percent encoding" do
    assert URL.parse("mailto:user@example.org?subject=caf%C3%A9") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Mailto{
          params: %{"subject" => "café"},
          to: ["user@example.org"]
        },
        path: "user@example.org",
        port: nil,
        query: "subject=caf%C3%A9",
        scheme: "mailto",
        userinfo: nil
      }
  end

  # test "utf-8 word encoding" do
  #   assert URL.parse("mailto:user@example.org?subject=%3D%3Futf-8%3FQ%3Fcaf%3DC3%3DA9%3F%3D") ==
  #
  # end
  #
  # test "iso8859 encoding" do
  #   assert URL.parse("mailto:user@example.org?subject=%3D%3Fiso-8859-1%3FQ%3Fcaf%3DE9%3F%3D") ==
  #
  # end

  test "utf8 encoding domain name" do
    assert URL.parse("mailto:user@%E7%B4%8D%E8%B1%86.example.org?subject=Test&body=NATTO") ==
      %URL{
        authority: nil,
        fragment: nil,
        host: nil,
        parsed_path: %URL.Mailto{
          params: %{"body" => "NATTO", "subject" => "Test"},
          to: ["user@納豆.example.org"]
        },
        path: "user@%E7%B4%8D%E8%B1%86.example.org",
        port: nil,
        query: "subject=Test&body=NATTO",
        scheme: "mailto",
        userinfo: nil
      }
    end
end