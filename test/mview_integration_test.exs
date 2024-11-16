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
    assert body =~ "test.md"
  end

  test "shows tab page" do
    response = HTTPoison.get! "http://localhost:4000/tab/Journal"
    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "test.md"
    assert body =~ "<a class=\"nav-link active\" href=\"/tab/Journal\">Journal</a>"
  end

  test "shows a  page" do
    response = HTTPoison.get! "http://localhost:4000/page/Journal/test.md"
    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "test file"
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

    text = "test"
    response = HTTPoison.post!("http://localhost:4000/search/Journal",
    {:form, [stext: text]}, %{"Content-Type" => "application/x-www-form-urlencoded"})
    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "a test file"
  end

end

