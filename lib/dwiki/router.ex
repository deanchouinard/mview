defmodule Dwiki.Router do
  use Plug.Router
  alias Dwiki.Page

  plug Plug.Parsers, parsers: [:urlencoded]
  plug :match
  plug :dispatch

  get "/" do
    page_contents =
      Page.show_page(conn.assigns.my_app_opts[:pages_dir], "index.md")

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  get "favicon.ico" do
    conn
  end

  get "/static/css/bootstrap.min.css" do
    page_contents = Page.bootstrap()
    conn
    |> put_resp_content_type("text/css")
    |> send_resp(200, page_contents)
  end

  get "/*path" do
    {code, page_contents} = case String.match?(List.last(path), ~r/\.md$/) do
      true -> {200, Page.show_page(conn.assigns.my_app_opts[:pages_dir], path)}
      _ -> {404, "not found"}
    end

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(code, page_contents)
  end

  post "/search" do
    page_text = conn.params["stext"]
    page_contents = Page.search_results(conn.assigns.my_app_opts[:pages_dir], page_text)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  post "save/*path" do
    page_path = conn.assigns.my_app_opts[:pages_dir]
    page_text = conn.params["pagetext"]
    File.write!(Path.join(page_path, path), page_text)
    page_contents = Page.show_page(page_path, path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  post "/*path" do
    page_contents = Page.edit_page(conn.assigns.my_app_opts[:pages_dir],  path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  match _, do: send_resp(conn, 404, "not found")


  def call(conn, opts) do
    conn = assign(conn, :my_app_opts, opts)
    super(conn, opts)
  end

end

