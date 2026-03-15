import Config

config :devtodo,
  ecto_repos: [Devtodo.Repo],
  generators: [timestamp_type: :utc_datetime]

config :devtodo, DevtodoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DevtodoWeb.ErrorHTML, json: DevtodoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Devtodo.PubSub,
  live_view: [signing_salt: "oH3zXj9P"]

config :devtodo, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

config :esbuild,
  version: "0.17.11",
  devtodo: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.4.3",
  devtodo: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
