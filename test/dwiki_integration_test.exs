defmodule DwikiIntegrationTest do
  use ExUnit.Case
  use Plug.Test

  doctest Dwiki

  setup_all do
    :os.cmd('rm test/pages/*')

    :ok
  end

  test "shows index.md page" do
    response = HTTPoison.get! "http://localhost:4000/"

    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "index.md"

  end

  test "edit and save a page" do
    response = HTTPoison.get! "http://localhost:4000/first.md"

    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response

    response = HTTPoison.post! "http://localhost:4000/first.md",
    "", [{"Content-Type", "application/x-www-form-urlencoded"}]
    #"{\"body\": \"body\"}", [{"Content-Type", "application/x-www-form-urlencoded"}]
    #"{\"body\": \"body\"}"
    assert %HTTPoison.Response{status_code: 200} = response
    %HTTPoison.Response{body: body} = response
    #    body = body <> "edit"

    [{_, _, [text]}] = Floki.find(body, "textarea")
    IO.puts text
    text = text <> " edit"

    response = HTTPoison.post! "http://localhost:4000/save/first.md",
    {:form, [pagetext: text]}, [{"Content-Type", "application/x-www-form-urlencoded"}]
    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "edit"
  end

  test "search" do
    response = HTTPoison.get! "http://localhost:4000/first.md"

    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "search"

    text = "first"
    response = HTTPoison.post! "http://localhost:4000/search",
      {:form, [stext: text]}, [{"Content-Type", "application/x-www-form-urlencoded"}]
    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "<a href=first.md>### first.md"
  end

end

