defmodule Mview.Config do

  def read_config do

    File.stream!(Path.join(File.cwd!, "mview.conf"))
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.filter(&String.length(&1) > 0)
    |> Enum.filter(&String.at(&1, 0) != "#")
    |> Enum.map(&String.split(&1, ",", trim: true))

  end
end

