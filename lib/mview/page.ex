defmodule Mview.Page do
  require EEx

  EEx.function_from_file(:def, :show_page_template,
    "templates/show_page.eex", [:page_contents, :tabs])
  EEx.function_from_file(:def, :layout_page_template,
    "templates/app.eex", [:body])
  EEx.function_from_file(:def, :search_results_page,
    "templates/search_results_page.eex", [:page_contents])
  EEx.function_from_file(:def, :bootstrap,
    "static/css/bootstrap.min.css")

  def index_page(%{dirs: dirs, sort:  sort} ) do
    [pages_dir, label] = List.first(dirs)
    tabs = build_tabs(dirs, label)
    page_contents = file_list(pages_dir, label, sort)
    build_page(page_contents, tabs)
  end

  defp build_page(page_contents) do
    layout_page_template(search_results_page(page_contents))
  end
  
  defp build_page(page_contents, tabs) do
    layout_page_template(show_page_template(page_contents, tabs))
  end

  def tab_page(%{dirs: dirs, sort: sort}, [label] = _x) do
    [pages_dir, label] = find_active_tab(dirs, label)
    tabs = build_tabs(dirs, label)
    page_contents = file_list(pages_dir, label, sort)
    build_page(page_contents, tabs)
  end

  # def bootstrap, do: File.read!("static/css/bootstrap.min.css")

  def show_page(%{dirs: dirs}, path) do
    [label, file_name] = path
    [pages_dir, _] = find_active_tab(dirs, label)
    page_path = Path.join(pages_dir, file_name)
    page_contents = File.read!(page_path)
    page_contents = Earmark.to_html(page_contents)
    build_page(page_contents, file_name)
  end

  def search_results(%{dirs: dirs}, stext, [label] = _t) do
    ##System.cmd("ack", [stext], cd: pages_dir)
    [pages_dir, _] = find_active_tab(dirs, label)

    results = Enum.map(File.ls!(pages_dir), fn(x) -> search_file(pages_dir, x,
      stext, label) end)
    build_page(results)
  end

  defp search_file(pages_dir, file, stext, label) do
    File.stream!(Path.join(pages_dir, file))
    |> Enum.filter(&(String.contains?(&1, stext)))
    |> Enum.map(&(make_link(&1, file, label)))
  end

  defp make_link(match, file, label) do
    "<a href=/page/#{label}/#{file}>#{match}</a> #{file}</br>"
  end

  def build_radio_buttons(sort, label) do
    chron_checked =
      case sort do
        "chron" -> "checked"
        _       -> ""
      end

    alpha_checked =
      case sort do
        "alpha" -> "checked"
        _       -> ""
      end

    """
    <form name="buttonForm" action="/tab/#{label}/">
      <label class="radio-inline"><input type="radio" name="sort" onclick="radioClick(this);" value="chron"
      #{chron_checked}> Chronological<br></label>
      <label class="radio-inline"><input type="radio" name="sort" onclick="radioClick(this);" value="alpha"
      #{alpha_checked}> Alphabetical<br></label>
    </form>
    <script>
    function radioClick(myRadio) {
      console.log(myRadio);
      myRadio.form.submit();
      };
    </script>
    """
  end

  def build_search_form(label) do
"""
    <hr>
    <form action="/search/#{label}" method="post">
      <input type="text" name="stext">
      <input type="submit" value="Search">
    </form>
"""
  end

  defp dtos(date), do: Date.from_erl!(date) |> Date.to_string

  defp build_tabs(dirs, label) do
    # tabs = ["<ul class=\"nav nav-tabs\">"]
    # tabs = tabs ++ Enum.map(dirs, fn(x) -> build_tab_item(List.last(x), label) end)
    # tabs ++ ["</ul>"]
    [["<ul class=\"nav nav-tabs\">"
      | Enum.map(dirs, fn(x) -> build_tab_item(List.last(x), label) end) ]
      | "</ul>"]
  end

  defp build_tab_item(label, match_label) do
    case label == match_label do
      true -> "<li class=\"active\"><a href=\"/tab/#{label}\">#{label}</a></li>"
      _    -> "<li><a href=\"/tab/#{label}\">#{label}</a></li>"
    end
  end

  defp file_list(pages_dir, label, sort) do
    File.ls!(pages_dir)
    |> Enum.map(fn(x) -> get_file_time(x, pages_dir) end)
    |> Enum.sort(sel_sort(sort))
    #|> Enum.sort(&(&1.d >= &2.d))
    # |> Enum.sort(&(String.upcase(&1.f) <= String.upcase(&2.f)))
    |> Enum.map(fn(x) -> make_file_link(x.f, x.d, label) end)
    # |> List.insert_at(0, build_search_form(label))
    |> List.insert_at(0, build_radio_buttons(sort, label))
    |> List.insert_at(0, ["<table class=\"table-condensed\"><thead><tr><th>Filename</th>
                <th>Date</th></thead><tbody>"])
    |> List.insert_at(-1, ["</tbody></table>"])
    |> List.insert_at(-1, build_search_form(label))
  end

  defp sel_sort(sort) do
    IO.inspect sort, label: "sort"
    case sort == "chron" do
      true -> &(&1.d >= &2.d)
      _    -> &(String.upcase(&1.f) <= String.upcase(&2.f))
      end
  end

  defp get_file_time(file, pages_dir) do
    %File.Stat{mtime: {dt, _tt}} = File.stat!(Path.join(pages_dir, file), time:
      :local)
    %{f: file, d: dt}
  end


  defp make_file_link(file, dt, label) do
    "<tr><td><a href=/page/#{label}/#{URI.encode(file)}>#{file}</a></td><td>#{dtos(dt)}</td></tr>"
  end

  def find_active_tab(dirs, label), do: Enum.find(dirs, fn([_a, b] = _x) -> b  == label end)
end

