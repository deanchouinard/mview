defmodule Mview.Router do
  use Plug.Router
  alias Mview.Page

  if Mix.env() == :dev do
    use Plug.Debugger, style: [primary: "#c0392b", accent: "#41B577"]
  end

  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:urlencoded]
  # plug :load_sort
  plug :dispatch

  get "/" do
      # page_contents = Task.Supervisor.async(Mview.TaskSupervisor, Page, :index_page,
      #  [ conn.assigns.my_app_opts ] ) |> Task.await
      # conn = load_sort(conn)
      # IO.inspect conn.assigns
    conn = load_sort(conn)
    page_contents = Page.index_page(conn.assigns.my_app_opts)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  get "/static/css/bootstrap.min.css" do
    page_contents = Page.bootstrap()
    conn
    |> put_resp_content_type("text/css")
    |> send_resp(200, page_contents)
  end

  get "/tab/*dir" do
    conn = load_sort(conn)
    page_contents = Page.tab_page(conn.assigns.my_app_opts, dir)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  get "/page/*path" do
    stext = conn.params["stext"]
    page_contents =
      Page.show_page(conn.assigns.my_app_opts, path, stext)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  post "/search/*tab" do
    page_text = conn.params["stext"]
    page_contents = Page.search_results(conn.assigns.my_app_opts,
    page_text, tab)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  # post "save/*path" do
  #   page_path = conn.assigns.my_app_opts[:pages_dir]
  #   page_text = conn.params["pagetext"]
  #   File.write!(Path.join(page_path, path), page_text)
  #   page_contents = Page.show_page(page_path, path)
  #
  #   conn
  #   |> put_resp_content_type("text/html")
  #   |> send_resp(200, page_contents)
  # end
  #
  # post "/*path" do
  #   page_contents = Page.edit_page(conn.assigns.my_app_opts[:pages_dir],  path)
  #
  #   conn
  #   |> put_resp_content_type("text/html")
  #   |> send_resp(200, page_contents)
  # end

  match _, do: send_resp(conn, 404, "not found")


  def call(conn, opts) do
    conn = assign(conn, :my_app_opts, opts)
    super(conn, opts)
  end

  # def load_sort(conn, []) do
  defp load_sort(conn) do
    # IO.inspect conn, label: "conn"
    # IO.inspect Map.has_key?(conn, :params), label: "Exists"
    # IO.inspect conn.params, label: "conn params"
    # IO.inspect Map.has_key?(conn.params, "sort"), label: "Sort Exists"
    #     IO.inspect conn.params["sort"]
    #     IO.inspect conn.assigns, label: "assigns"
    if Map.has_key?(conn.params, "sort") do
      IO.puts "has sort"
      lsort = conn.params["sort"]
      #      lsort = :chron
      assign(conn, :my_app_opts , %{conn.assigns.my_app_opts | sort: lsort})
      #IO.inspect conn.assigns.my_app_opts, label: "my app opts"
        #      conn
    else
      IO.puts "no param sort"
      conn
    end
  end
end

