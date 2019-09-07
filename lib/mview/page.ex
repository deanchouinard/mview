defmodule Mview.Page do
  alias Mview.Search

  require EEx

  EEx.function_from_file(:def, :show_page_template,
    "templates/show_page.eex", [:page_contents, :tabs])
  EEx.function_from_file(:def, :layout_page_template,
    "templates/app.eex", [:body])
  EEx.function_from_file(:def, :search_results_page,
    "templates/search_results_page.eex", [:page_contents])
  # EEx.function_from_file(:def, :bootstrap,
  #   "static/css/bootstrap.min.css")
  EEx.function_from_file(:def, :bootstrap,
    "/home/deanchouinard/media/bootstrap-4.2.1-dist/css/bootstrap.min.css")
    # "static/css/bootstrap.min.css")
  EEx.function_from_file(:def, :mview_css,
    "templates/mview.css")

  def index_page(%{dirs: dirs, sort: sort, tab: label} ) do
    IO.inspect dirs, label: "dirs"
    IO.inspect label, label: "label"
    # [pages_dir, _] = List.first(dirs) # todo: get pages_dir by looking up label in dirs?
    [pages_dir, _] = Enum.find(dirs, fn [_, y] -> y == label end)
    # [pages_dir, label] = List.first(dirs)
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

  def tab_page(%{dirs: dirs, sort: sort}, label) do
    [pages_dir, label] = find_active_tab(dirs, label)
    tabs = build_tabs(dirs, label)
    page_contents = file_list(pages_dir, label, sort)
    build_page(page_contents, tabs)
  end

  # def bootstrap, do: File.read!("static/css/bootstrap.min.css")

  def show_page(%{dirs: dirs} = _opts, path, stext) do
    IO.inspect path, label: "path: "
    [label, file_name] = path
    [pages_dir, _] = find_active_tab(dirs, label)
    page_path = Path.join(pages_dir, file_name)
    page_contents = [ insert_find_script(stext) ]
    page_contents = [ page_contents | File.read!(page_path)
                    |> Earmark.as_html!(%Earmark.Options{breaks: true})
                    |> String.replace("<blockquote>", "<blockquote class=\"blockquote\">") ]
    build_page(page_contents, file_name)
  end

  #def search_results(%{dirs: dirs}, stext, [label] = _t) do
  def search_results(%{dirs: dirs}, stext, label) do
    [pages_dir, _] = find_active_tab(dirs, label)

    results = case Search.search(pages_dir, stext) do
      ["No matches."] -> "No matches"
      results ->
        results = Enum.map(results, fn x -> make_link(x.text, x.fname, x.line, label, stext) end)
        results = ["<table class=\"table-condensed\"><thead><tr><th>Results</th>
                <th>Filename</th></thead><tbody>" | results]
        List.insert_at(results, -1, ["</tbody></table>"])
    end
    build_page(results)
  end

  # defp search_file(pages_dir, file, stext, label) do
  #   File.stream!(Path.join(pages_dir, file))
  #   |> Enum.filter(&(String.contains?(&1, stext)))
  #   |> Enum.map(&(make_link(&1, file, label)))
  # end

  defp make_link(match, file, line, label, stext) do
    """
    <tr>
    <td>
    <a href=/page/#{label}/#{file}?stext=#{URI.encode(stext)}>#{remove_angle_brackets(match)}</a> </td>
    <td>#{file}:#{line}</br> </td>
    </tr>
    """
  end

  defp remove_angle_brackets(str) do
    str
    |> String.replace("<", "")
    |> String.replace(">", "")
  end

  defp insert_find_script(stext) do
    """
    <script>
      this.onload = function(){ this.find("#{stext}", 0, 0, 1, 0, 0, 1);}
    </script>
    """
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
    <div class="form-check form-check-inline">
      <input class="form-check-input" type="radio" name="sort"
        onclick="radioClick(this)" id="inlineRadio1" value="chron" #{chron_checked}>
      <label class="form-check-label" for="inlineRadio1"> Chronological</label>
    </div>
    <div class="form-check form-check-inline">
      <input class="form-check-input" type="radio" name="sort"
        onclick="radioClick(this)" id="inlineRadio2" value="alpha" #{alpha_checked}>
      <label class="form-check-label" for="inlineRadio2">Alphabetical</label>
    </div>
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
<form  action="/search/#{label}" method="post">
  <div class="form-row">
    <div class="col-4">
      <input class="form-control form-control-sm" type="text" placeholder="Search text" name="stext">
    </div>
    <div class="col">
      <button type="submit" class="btn btn-primary btn-sm">Search</button>
    </div>
  </div>
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
      true -> "<li class=\"nav-item\"><a class=\"nav-link active\" href=\"/tab/#{label}\">#{label}</a></li>"
      _    -> "<li class=\"nav-item\"><a class=\"nav-link\" href=\"/tab/#{label}\">#{label}</a></li>"
    end
  end

  defp file_list(pages_dir, label, sort) do
    File.ls!(pages_dir)
    |> Enum.map(fn(x) -> get_file_time(x, pages_dir) end)
    |> Enum.sort(sel_sort(sort))
    #|> Enum.sort(&(&1.d >= &2.d))
    # |> Enum.sort(&(String.upcase(&1.f) <= String.upcase(&2.f)))
    |> Enum.map(fn(x) -> make_file_link(x.f, x.d, label) end)
    |> List.insert_at(0, ["<table class=\"table table-borderless table-sm\"><thead><tr><th style=\"width: 20%\" scope=\"col\">Filename</th>
                <th scope=\"col\">Date</th></thead><tbody>"])
    |> List.insert_at(0, build_search_form(label))
    |> List.insert_at(0, build_radio_buttons(sort, label))
    |> List.insert_at(-1, ["</tbody></table>"])
    # |> List.insert_at(-1, build_search_form(label))
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
