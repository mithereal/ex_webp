import Config

config :webp,
  path: "/usr/bin/cwebp",
  location: ""

import_config "#{config_env()}.exs"
