defmodule Webp do
  @moduledoc """
  Webp is a installer and runner for [Webp].

  ## Profiles

  You can define multiple configuration profiles. By default, there is a
  profile called `:default` which you can configure its args, current
  directory and environment:

      config :webp,
        default: [
          location: Path.expand("../priv/static/images/", __DIR__),
          destination: Path.expand("../priv/static/images/", __DIR__)
        ]

  ## Webp configuration

  There are two global configurations for the `webp` application:

    * `:path` - the path to the webp executable.

  Once you find the location of the executable, you can store it in a
  `MIX_WEBP_PATH` environment variable, which you can then read in
  your configuration file:

      config :webp, path: System.get_env("MIX_WEBP_PATH")

  """

  use Application
  require Logger

  @doc false
  def start(_, _) do
    Supervisor.start_link([], strategy: :one_for_one)
  end

  @doc """
  Returns the configuration for the given profile.

  Returns nil if the profile does not exist.
  """
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:webp, profile) ||
      raise ArgumentError, """
      unknown webp profile. Make sure the profile named #{inspect(profile)} is defined in your config files, such as:

          config :webp,
            #{profile}: [
              location: Path.expand("../assets", __DIR__),
              destination: Path.expand("../priv/static/images/", __DIR__)
            ]
      """
  end

  @doc false
  def script_path() do
    Path.join(:code.priv_dir(:webp), "webp.bash")
  end


  defp cmd(command, args, opts) do
    System.cmd(command, args, opts)
  end

  @doc """
  Runs the given command with `args`.

  The given args will be appended to the configured args.
  The task output will be streamed directly to stdio. It
  returns the status of the underlying call.
  """
  def run(profile, extra_args) when is_atom(profile) and is_list(extra_args) do
    config = config_for!(profile)
    location = config[:location] || []
    destination = config[:destination] || nil
    quality = config[:quality] || 80

    if location == [] and extra_args == [] do
      raise "no arguments passed to webp"
    end

    opts = [
      cd: config[:location] || File.cwd!(),
      env: config[:env] || %{},
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    args = [location] ++ extra_args
    glob = location <> "/*"

    files = Path.wildcard(glob)

    for source <- files do
      path = bin_path()

      valid_extension =
        Path.extname(source) in Application.get_env(:webp, :image_extensions, [
          ".png",
          ".jpg",
          ".jpeg"
        ])

      case valid_extension do
        true ->
          extname = Path.extname(source)

          filename = Path.basename(source, extname)

          destination = config[:destination] || Path.basename(source, extname)

          params = ["-quiet", "#{source}", "-o", "#{destination}.webp"]

          path =
            if "--watch" in args do
              [script_path() | path]
            else
              path
            end

          path
          |> cmd(params, opts)
          |> elem(1)

        false ->
          :error
      end
    end
  end

  @doc """
  Returns the path to the executable.

  The executable may not be available if it was not yet installed.
  """
  def bin_path do
    Application.get_env(:webp, :path, "/usr/bin/cwebp")
  end

  @doc """
  Convert Source to Destination `args`.

  """
  def convert(source, params \\ []) do
    opts = [
      cd: params[:location] || File.cwd!(),
      env: params[:env] || %{},
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    path = bin_path()

    unless File.exists?(path) do
      raise "#{} Not Found please set path to the cwebp location"
    end

    valid_extension =
      Path.extname(source) in Application.get_env(:webp, :image_extensions, [
        ".png",
        ".jpg",
        ".jpeg"
      ])

    case valid_extension do
      true ->
        extname = Path.extname(source)

        filename = Path.basename(source, extname)

        destination = params[:destination] || Path.basename(source, extname)

        params = ["-quiet", "#{source}", "-o", "#{destination}.webp"]

        path
        |> cmd(params, opts)
        |> elem(1)

      false ->
        :error
    end
  end

  @doc """
  Convert Source to Destination if cwebp exists.

  """
  def install_and_run(profile, args) do
    unless File.exists?(bin_path()) do
      raise "#{} Not Found please set path to the cwebp location"
    end

    run(profile, args)
  end
end
