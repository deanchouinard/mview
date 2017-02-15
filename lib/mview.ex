defmodule Mview do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = Application.get_env(:mview, :cowboy_port, 4000)

    dirs = Mview.Config.read_config()
    IO.inspect dirs

    pages_dir = case Mix.env do
      :test ->
        Path.join(File.cwd!(), "test/pages")
      _ ->
        Path.join(File.cwd!(), "pages")
    end
    
    # unless File.exists?(pages_dir) do
    #   File.mkdir!(pages_dir)
    # end

    dparams = [ test: "test", pages_dir: pages_dir, dirs: dirs ]

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

  def main(args) do
    IO.puts "Starting Mview..."
    :timer.sleep(:infinity)
  end

end
