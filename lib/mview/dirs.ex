defmodule Mview.Dirs do
  use Agent

  defstruct dirs: [], sort: ""

  def start_link() do
    Agent.start_link(fn -> init_dirs() end, name: __MODULE__)
  end

  def update_dirs(new_dirs) do
    Agent.update(__MODULE__, fn x -> %{x | dirs: new_dirs} end)
  end

  def get_dparams() do
    Agent.get(__MODULE__, fn x -> x end)
  end

  def init_dirs() do
    dirs = load_subdirs()
    sort = "chron"
    struct(Mview.Dirs, [dirs: dirs, sort: sort])
  end

  def load_subdirs() do
    cwd = File.cwd!()
    data_path = Application.get_env(:mview, :data_path)
    pages_dir = case data_path do
      nil ->
        cwd
      _ ->
        Path.join(cwd, "test/test_data")
    end
    File.cd!(pages_dir)

    dirs = File.ls!(pages_dir)
    |> Enum.filter(fn(x) -> is_dir(x) end)
    |> Enum.reject(fn(x) -> is_hidden_dir(x) end)
    |> Enum.map(fn(x) -> [x, x] end)
    |> Enum.map(fn(x) -> add_full_path(x, pages_dir) end)
    |> Enum.map(fn(x) -> add_tab_label(x) end)

    File.cd!(cwd)
    dirs
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

