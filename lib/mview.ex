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
    # cwd = File.cwd!()
    # pages_dir = case Mix.env do
    #   :test ->
    #     Path.join(cwd, "test/test_data")
    #   :dev ->
    #     Path.join(cwd, "test/test_data")
    #     # cwd
    #   _ ->
    #     cwd
    # end
    # File.cd!(pages_dir)
    #
    # IO.inspect pages_dir, label: "pages_dir: "
    # dirs = Mview.Dirs.load_subdirs(pages_dir)
    # IO.inspect dirs, label: "dirs"
    # unless File.exists?(pages_dir) do
    #   File.mkdir!(pages_dir)
    # end

#    dparams = %{ dirs: dirs, sort: "chron" }
    #dparams = %{ test: "test", pages_dir: pages_dir, dirs: dirs, sort: "chron" }

      IO.puts "port: #{port}"
    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Mview.Worker.start_link(arg1, arg2, arg3)
      # worker(Mview.Worker, [arg1, arg2, arg3]),
      # Plug.Cowboy.child_spec( [ scheme: :http, plug: { Mview.Router, dparams }, port: port ]),
      # { Plug.Cowboy, scheme: :http, plug: { Mview.Router, dparams }, options: [port: port] },
      { Plug.Cowboy, scheme: :http, plug: { Mview.Router, [] }, options: [port: port] },
      #supervisor(Task.Supervisor, [[name: Mview.TaskSupervisor]]),
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

end
