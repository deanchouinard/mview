defmodule Mix.Tasks.Mview.Wrt do
  use Mix.Task

  @shortdoc "Builds and copies escript to wrt directory"

  def run(_) do
    Mix.Shell.IO.info("Starting wrt...")
    # Mix.Task.run("MIX_ENV=prod escript.build")
    Mix.Shell.IO.cmd("MIX_ENV=prod mix escript.build")
    # Mix.Shell.IO.info("build escript")
    # Mix.Shell.IO.cmd("cp /Users/dean/wrk/elixir/mview/mview /Users/dean/wrk/wrt/")
    Mix.Shell.IO.cmd("cp /home/dean/wrk/elixir/mview/mview /home/dean/wrk/wrt/")
    Mix.Shell.IO.cmd("ls -al /home/dean/wrk/wrt/mview")
  end

end

