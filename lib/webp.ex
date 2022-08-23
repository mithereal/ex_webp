defmodule Webp do
  @moduledoc """
  Webp is a installer and runner for [Webp].

  ## Profiles

  You can define multiple configuration profiles. By default, there is a
  profile called `:default` which you can configure its args, current
  directory and environment:

      config :webp,
        default: [
          location: "static/images",
          cd: Path.expand("../assets", __DIR__)
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
              location: "assets/images/",
              cd: Path.expand("../assets", __DIR__)
            ]
      """
  end

  @doc false
  def script_path() do
    Path.join(:code.priv_dir(:webp), "webp.bash")
  end

  defp cmd(path, args) do
    cmd(path, args, [])
  end

  defp cmd([command | args], extra_args, opts) do
    System.cmd(command, args ++ extra_args, opts)
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

    if location == [] and extra_args == [] do
      raise "no arguments passed to webp"
    end

    opts = [
      cd: config[:cd] || File.cwd!(),
      env: config[:env] || %{},
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    quality = extra_args[:quality] || 80

    args = ([location] ++ extra_args) |> Map.drop([:quality])

    files = File.glob(location)

    for source <- files do
      path = Application.get_env(:webp, :path, "/usr/bin/cwebp")

      extname = Path.extname(source)

      destination = Path.basename(source, extname)

      params = "-q #{quality}} #{source} -o #{destination}"

      command = path <> params

      path =
        if "--watch" in args do
          [script_path() | command]
        else
          command
        end

      path
      |> cmd(args, opts)
      |> elem(1)
    end
  end

  @doc """
  Returns the path to the executable.

  The executable may not be available if it was not yet installed.
  """
  def bin_path do
    Application.get_env(:cwebp, :path)
  end

  defp path_exists?(path) do
    Enum.all?(path, &File.exists?/1)
  end

  @doc """
  Convert Source to Destination `args`.

  """
  def convert(source, extra_args \\ []) do
    opts = [
      cd: extra_args[:cd] || File.cwd!(),
      env: extra_args[:env] || %{},
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    quality = extra_args[:quality] || 80

    path = Application.get_env(:webp, :path, "/usr/bin/cwebp")

    extname = Path.extname(source)

    destination = Path.basename(source, extname)

    params = ["-q #{quality}}", "#{source} -o #{destination}"]

    path
    |> cmd(params, opts)
    |> elem(1)
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
