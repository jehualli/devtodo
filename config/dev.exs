import Config

config :devtodo, Devtodo.Repo,
  database: Path.expand("../devtodo_dev.db", __DIR__),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :devtodo, DevtodoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev_secret_key_base_at_least_64_chars_long_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:devtodo, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:devtodo, ~w(--watch)]}
  ]

config :devtodo, DevtodoWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/devtodo_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :devtodo, :dns_cluster_query, nil

config :logger, level: :debug

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true
