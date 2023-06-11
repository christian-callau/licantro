defmodule Licantro.Roles do
  def get_roles do
    :licantro
    |> :code.priv_dir()
    |> Path.join("data/roles.yml")
    |> YamlElixir.read_from_file!()
  end
end
