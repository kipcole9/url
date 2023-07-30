defmodule MailtoTest do
  use ExUnit.Case

  test "simple mailto" do
    assert URL.new("mailto:infobot@example.com?subject=current-issue") ==
             {:ok,
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
              }}
  end

  test "with params" do
    assert URL.new("mailto:infobot@example.com?body=send%20current-issue%0D%0Asend%20index") ==
             {:ok,
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
              }}
  end

  test "percent decode address" do
    assert URL.new("mailto:gorby%25kremvax@example.com") ==
             {:ok,
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
              }}
  end

  test "more complications" do
    assert URL.new("mailto:%22not%40me%22@example.org") ==
             {:ok,
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
              }}

    assert URL.new("mailto:%22oh%5C%5Cno%22@example.org") ==
             {:ok,
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
              }}
  end

  test "simple utf8 percent encoding" do
    assert URL.new("mailto:user@example.org?subject=caf%C3%A9") ==
             {:ok,
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
              }}
  end

  test "utf8 encoding domain name" do
    assert URL.new("mailto:user@%E7%B4%8D%E8%B1%86.example.org?subject=Test&body=NATTO") ==
             {:ok,
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
              }}
  end
end
