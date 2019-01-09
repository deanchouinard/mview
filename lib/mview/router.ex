defmodule Mview.Router do
  use Plug.Router
  alias Mview.Page

  if Mix.env() == :dev do
    use Plug.Debugger, style: [primary: "#c0392b", accent: "#41B577"]
  end

  plug Plug.Logger
  plug :put_secret_key_base
  plug Plug.Session, store: :cookie, key: "_mview",
    encryption_salt: "mview salt blah blah blaha",
    signing_salt: "dfklj dlkjl eoienl dklsd",
    key_length: 64,
    log: :debug

  plug :load_session
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
    IO.puts "after page contents"
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

  get "/static/css/mview.css" do
    page_contents = Page.mview_css()
    conn
    |> put_resp_content_type("text/css")
    |> send_resp(200, page_contents)
  end

  get "/clean" do
    conn = configure_session(conn, drop: true)
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "session dropped")
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
    
    IO.inspect path, label: "path: "
    [label, file_name] = path
    IO.inspect conn.assigns.my_app_opts, label: "my_app_opts"
    %{dirs: dirs} = conn.assigns.my_app_opts
    [pages_dir, _] = Mview.Page.find_active_tab(dirs, label)
    page_path = Path.join(pages_dir, file_name)
    IO.inspect pages_dir, label: "pages_dir"
    IO.inspect page_path, label: "page_path"
    IO.inspect conn.assigns, label: "assigns"

    conn = case File.stat(page_path) do
      {:ok, %File.Stat{ type: :directory }} -> 
        #    add_a_tab(opts, path)
        IO.inspect conn.assigns.my_app_opts.dirs, label: "conn assigns dirs"
        IO.inspect conn.assigns.my_app_opts.dirs ++ [[page_path, file_name]]
        new_dirs = conn.assigns.my_app_opts.dirs ++ [[page_path, file_name]]
        dparams = %{ dirs: new_dirs, sort: "chron" }
        conn = assign(conn, :my_app_opts, dparams)
        conn = fetch_session(conn)
        conn = put_session(conn, :sdirs, dparams)
        # IO.inspect conn, label: "conn"
      { _, _ } -> conn

    end
    #    IO.puts "**#{page_contents}**"
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


  #  def call(conn, opts) do
  # IO.puts "call"
    # conn = fetch_session(conn)
    # opts = if dopt = get_session(conn, :sdirs) do
    #   dopt
    # else
    #   opts
    # end
    # conn = assign(conn, :my_app_opts, opts)
    # super(conn, opts)
    #end

  defp load_session(conn, []) do

    conn = fetch_session(conn)
    dopt = get_session(conn, :sdirs)
      
    conn = case dopt do
      nil ->
        IO.puts "no session found"
        dirs = Mview.Dirs.load_subdirs()
        dparams = %{ dirs: dirs, sort: "chron" }
        conn = put_session(conn, :sdirs, dparams)
        conn = assign(conn, :my_app_opts, dparams)
      _ -> 
        IO.puts "session found"
        conn = assign(conn, :my_app_opts, dopt)
    end

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

  defp put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, "jdfdsfslkjfdslkkjdfksldjlksdfjlsjlkljkdfjdslkfsjljslklkddsjfslkdslldksdjlk"
  end
end

