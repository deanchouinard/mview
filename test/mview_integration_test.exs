defmodule MviewIntegrationTest do
  use ExUnit.Case
  use Plug.Test

  doctest Mview

  setup_all do
#    :os.cmd('rm test/pages/*')

    :ok
  end

  test "shows index page" do
    response = HTTPoison.get! "http://localhost:4000/"

    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "first.md"

  end

  @tag :pending
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
    response = HTTPoison.get! "http://localhost:4000/"

    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "search"

    text = "first"
    response = HTTPoison.post! "http://localhost:4000/search/Writing",
      {:form, [stext: text]}, [{"Content-Type", "application/x-www-form-urlencoded"}]
    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "<a href=/page/Writing/first.md>### first.md"
  end

end

