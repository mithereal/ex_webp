import Config

config :webp,
  path: "/usr/bin/cwebp",
  location: Path.expand("../priv/static/images", __DIR__),
  destination: Path.expand("../priv/static/images", __DIR__)

import_config "#{config_env()}.exs"
