defmodule Webp.Compressor do
  @behaviour Phoenix.Digester.Compressor

  def compress_file(file_path, content) do
    valid_extension = Path.extname(file_path) in Application.get_env(:webp, :image_extensions, [".png", ".jpg", ".jpeg"])
    supported_formats = :eimp.is_supported(:webp)

    case valid_extension && supported_formats do
      true ->
        compressed_content = convert(content, :webp)

        case compressed_content do
          {:ok, data} ->
            {:ok, data}

          error ->
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
        {:error, "no eimp application"}
    end
  end
end
