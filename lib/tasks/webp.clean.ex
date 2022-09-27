defmodule Mix.Tasks.Webp.Clean do
  @moduledoc """
  Cleand webp at path.

  Usage:

       mix webp.delete "/path"
  """

  @shortdoc "Cleans webp at path "

  use Mix.Task

  @impl true
  def run(path \\ nil) do
    images_path =
      case is_nil(path) do
        true ->
          default_phx_path = Path.expand("../priv/static/images", __DIR__)
          Application.get_env(:webp, :location, default_phx_path)

        false ->
          default_path = Path.expand("../#{path}", __DIR__)
          Application.get_env(:webp, :location, default_path)
      end

    opts = [
      cd: images_path || File.cwd!(),
      env:  %{},
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    images_path =  "*.webp"
    System.cmd("rm", [images_path], opts)
  end
end
