defmodule Mix.Tasks.Mview.Server do
  use Mix.Task
  require Logger

  @shortdoc "Runs the Mview server"

  def run(args) do
    Logger.info("Starting Mview Server")
    Mix.Tasks.Run.run(args ++ ["--no-halt"])
  end
end

