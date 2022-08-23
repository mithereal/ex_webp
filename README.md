# ExWebp

[![CI](https://github.com/mithereal/ex_webp/actions/workflows/main.yml/badge.svg)](https://github.com/mithereal/ex_webp/actions/workflows/main.yml)

Mix tasks for installing and invoking [webp](https://github.com/mithereal/ex_webp/).

## Installation

If you are going to build assets in production, then you add
`webp` as a dependency on all environments but only start it
in dev:

```elixir
def deps do
  [
    {:webp, "~> 0.1", runtime: Mix.env() == :dev}
  ]
end
```

However, if your assets are precompiled during development,
then it only needs to be a dev dependency:

```elixir
def deps do
  [
    {:webp, "~> 0.1", only: :dev}
  ]
end
```

## Usage: there are 2 ways to use as a mix task or as a library -- mix task usage detailed below

```

invoke webp with:

```bash
$ mix webp default "assets/images/"
```


## Profiles

The first argument to `webp` is the execution profile.
You can define multiple execution profiles with the current
directory, the OS environment, and default arguments to the
`webp` task:

```elixir
config :webp,
  default: [
    location: "assets/images",
    cd: Path.expand("../assets/images", __DIR__)
  ]
```

When `mix webp default` is invoked, the task arguments will be appended
to the ones configured above.

## Adding to Phoenix

To add `webp` to an application using Phoenix, you need only four steps.
Note that installation requires that Phoenix watchers can accept `MFArgs`
tuples – so you must have Phoenix > v1.5.9.

First add it as a dependency in your `mix.exs`:

```elixir
def deps do
  [
    {:phoenix, "~> 1.6.0"},
    {:webp, "~> 0.1", runtime: Mix.env() == :dev}
  ]
end
```

Now let's configure `webp` to use `assets/images/` as the input file and
compile CSS to the output location `priv/static/assets/images/`:

```elixir
config :webp,
  default: [
    args: "assets/images",
    cd: Path.expand("../assets/images", __DIR__)
  ]
```

> Note: if you are using esbuild (the default from Phoenix v1.6),
> make sure you remove the `import "../css/app.css"` line at the
> top of assets/js/app.js so `esbuild` stops generating css files.

> Note: make sure the "assets" directory from priv/static is listed
> in the :only option for Plug.Static in your endpoint file at,
> for instance `lib/my_app_web/endpoint.ex`.

For development, we want to enable watch mode. So find the `watchers`
configuration in your `config/dev.exs` and add:

```elixir
  webp: {
    Webp,
    :run,
    [:default, "assets/images/"]
  }
```

Note we are embedding source maps with absolute URLs and enabling the file system watcher.

Finally, back in your `mix.exs`, make sure you have an `assets.deploy`
alias for deployments

```elixir
"assets.deploy": [
  "esbuild default --minify",
  "webp default",
  "phx.digest"
]
```

## css webp support
you will need to create webp styles in css and toggle then with some js, i load [modernizer](https://modernizr.com) with webp support in the layout
below is an example css

```css
.no-webp .img-class {
background-image: url("../images/img.png");
background-repeat: no-repeat;
left: 100px;
position: absolute;
height: 411px;
width: 745px;
}
             
.webp .img-class {
background-image: url("../images/img.webp");
background-repeat: no-repeat;
left: 100px;
position: absolute;
height: 411px;
width: 745px;
}
```

## Acknowledgements

This package is based on the excellent [esbuild](https://github.com/phoenixframework/esbuild) by Wojtek Mach and José Valim.

## License

Copyright (c) 2022 mithereal.

webp source code is licensed under the [MIT License](LICENSE.md).
