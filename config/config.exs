import Config

config :phoenix, :json_library, Jason

config :webp,
  image_extensions: [".png", ".jpg", ".jpeg"],
  path: "/usr/bin/cwebp",
  location: Path.expand("../priv/static/images", __DIR__),
  destination: Path.expand("../priv/static/images", __DIR__)

import_config "#{config_env()}.exs"
