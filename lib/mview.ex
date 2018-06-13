defmodule Mview do
  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = Application.get_env(:mview, :cowboy_port, 4100)
    Logger.info("Mview running or port: #{port}")

    # dirs = Mview.Config.read_config()
    # IO.inspect dirs
    cwd = File.cwd!()
    pages_dir = case Mix.env do
      :test ->
        Path.join(cwd, "test/pages")
      :dev ->
        #        Path.join(cwd, "pages")
        cwd
      _ ->
        cwd
    end
    
    dirs = load_subdirs(pages_dir)
    IO.inspect dirs, label: "dirs"
    # unless File.exists?(pages_dir) do
    #   File.mkdir!(pages_dir)
    # end

    dparams = %{ dirs: dirs, sort: "chron" }
    #dparams = %{ test: "test", pages_dir: pages_dir, dirs: dirs, sort: "chron" }

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Mview.Worker.start_link(arg1, arg2, arg3)
      # worker(Mview.Worker, [arg1, arg2, arg3]),
      Plug.Adapters.Cowboy.child_spec(:http, Mview.Router, dparams,
        port: port),
      supervisor(Task.Supervisor, [[name: Mview.TaskSupervisor]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mview.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def main(_args) do
    IO.puts "Starting Mview..."
    :timer.sleep(:infinity)
  end

  def load_subdirs(cwd) do
    File.ls!(cwd)
    |> Enum.filter(fn(x) -> is_dir(x) end)
    |> Enum.reject(fn(x) -> is_hidden_dir(x) end)
    |> Enum.map(fn(x) -> [x, x] end)
    |> Enum.map(fn(x) -> add_full_path(x, cwd) end)
    |> Enum.map(fn(x) -> add_tab_label(x) end)
  end

  defp add_tab_label([path, label]) do
    file = File.ls!(path) |> Enum.filter(&has_config_file(&1))
    case file do
      [] ->
        [path, label]
      _ ->
        [path, contents(Path.join(path, file))]
    end
  end

  defp contents(file), do: File.read!(file) |> String.replace("\n", "")

  defp has_config_file(".mview_label"), do: true
  defp has_config_file(_), do: false

  defp add_full_path([dir_name, label], cwd), do: [Path.join(cwd, dir_name), label]

  defp is_hidden_dir("." <> _rest), do: true
  defp is_hidden_dir("_" <> _rest), do: true
  defp is_hidden_dir(_), do: false

  defp is_dir(path) do
    fstat = File.stat!(path)
    case fstat.type do
      :directory ->
        true
      _ ->
        false
    end
  end

end
