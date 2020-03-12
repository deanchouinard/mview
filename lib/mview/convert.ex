defmodule Mview.Convert do

  def as_html!(page_path) do

    # System.cmd("pandoc", ["-niHdskip", "#{stext}" | Path.wildcard("#{path}/*")]) do

    #    :os.cmd('echo \"#{source}\" | pandoc')

    {contents, status} = System.cmd("pandoc", [page_path, "-f", "gfm+hard_line_breaks", "-t", "html"])
    IO.inspect status, label: "pandoc status:"
    contents = case status do
      0 -> contents
      _ -> "<br/>File not found."
    end
  end

end
