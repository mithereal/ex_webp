defmodule Mix.Tasks.Webp do
  @moduledoc """
  Invokes webp with the given args.

  Usage:

       mix webp TASK_OPTIONS PROFILE

  Example:

       mix webp default

  ## Options

    * `--runtime-config` - load the runtime configuration before executing
      command

  Note flags to control this Mix task must be given before the profile:

       mix webp --runtime-config default
  """

  @shortdoc "Invokes webp with the profile and args"

  use Mix.Task

  @impl true
  def run(args) do
    switches = [runtime_config: :boolean]
    {opts, remaining_args} = OptionParser.parse_head!(args, switches: switches)

    if opts[:runtime_config] do
      Mix.Task.run("app.config")
    else
      Application.ensure_all_started(:webp)
    end

    Mix.Task.reenable("webp")
    run(remaining_args)
  end
end
