defmodule Mview.Convert do

  def as_html!(page_path) do

    # from_string = "gfm+hard_line_breaks+footnotes"
    from_string = "markdown_github+hard_line_breaks+footnotes"

    # System.cmd("pandoc", ["-niHdskip", "#{stext}" | Path.wildcard("#{path}/*")]) do

    #    :os.cmd('echo \"#{source}\" | pandoc')

    {contents, status} = System.cmd("pandoc", [page_path, "--from", "#{from_string}", "-t", "html"])
    IO.inspect status, label: "pandoc status:"
    _contents = case status do
      0 -> contents
      _ -> "<br/>File not found."
    end
  end

end
