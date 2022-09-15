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

    images_path = images_path <> "/*webp"
    System.cmd("rm", [images_path], [])
  end

  def run(path, opts) do
    default_phx_path = Path.expand("../#{path}", __DIR__)
    images_path = Application.get_env(:webp, :location, default_phx_path)

    glob = "#{images_path}/*.webp"
    System.cmd("rm", [glob], opts)
  end
end
