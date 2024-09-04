defmodule Webp.Compressor do
  @behaviour Phoenix.Digester.Compressor

  require Logger

  def compress_file(file_path, content) do
    valid_extension =
      Path.extname(file_path) in Application.get_env(:webp, :image_extensions, [
        ".png",
        ".jpg",
        ".jpeg"
      ])

    case valid_extension do
      true ->
        compressed_content =
          convert(content, :webp, file_path)

        case compressed_content do
          {:ok, data} ->
            {:ok, data}

          _ ->
            :error
        end

      false ->
        :error
    end
  end

  def file_extensions do
    [".webp"]
  end

  defp convert(content, options, file_path) do
    cond do
      Code.ensure_loaded?(:eimp) and function_exported?(:eimp, :convert, 2) ->
        :eimp.convert(content, options)

      false ->
        location = Application.get_env(:webp, :destination)
        params = %{location: location}
        Webp.convert(file_path, params)
        :error
    end
  end
end
