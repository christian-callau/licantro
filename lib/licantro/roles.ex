defmodule Licantro.Roles do
  def get_roles do
    :licantro
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:path)
    |> YamlElixir.read_from_file!()
  end
end
