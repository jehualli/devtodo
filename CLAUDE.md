# CLAUDE.md — devtodo

Elixir 1.14+ / Phoenix 1.7 LiveView task tracker, SQLite via `ecto_sqlite3`.
Dark theme.

- `mix setup` is the non-obvious one: it installs deps, creates the DB, migrates,
  seeds, and builds assets in a single step. Run it before `mix phx.server` (**:4000**).
- Keyboard shortcuts in the UI: `N` = new task · `/` = search · `Esc` = clear filters.
