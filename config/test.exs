import Config

config :devtodo, Devtodo.Repo,
  database: Path.expand("../devtodo_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

config :devtodo, DevtodoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_at_least_64_chars_long_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view, enable_expensive_runtime_checks: true
