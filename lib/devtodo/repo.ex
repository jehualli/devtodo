defmodule Devtodo.Repo do
  use Ecto.Repo,
    otp_app: :devtodo,
    adapter: Ecto.Adapters.SQLite3
end
