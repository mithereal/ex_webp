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

    if :eimp.is_supported(:webp) == false && Mix.env() in [:dev, :test]  do
      Logger.error("libwebp Not Found")
    end

    case valid_extension && :eimp.is_supported(:webp) do
      true ->
        compressed_content = convert(content, :webp)

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

  defp convert(content, options) do
    cond do
      Code.ensure_loaded?(:eimp) and function_exported?(:eimp, :convert, 2) ->
        :eimp.convert(content, options)

      false ->
        if Mix.env() in [:dev, :test] do
          Logger.error(":eimp Not Found")
        end

        :error
    end
  end
end
