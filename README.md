# DevTodo

A developer task tracker built with Phoenix LiveView, Elixir, and SQLite. Designed for daily use — fast, keyboard-friendly, and zero external dependencies.

![Elixir](https://img.shields.io/badge/Elixir-1.14+-purple) ![Phoenix](https://img.shields.io/badge/Phoenix-1.7+-orange) ![SQLite](https://img.shields.io/badge/SQLite-local-blue)

## Features

- **Live UI** — Phoenix LiveView, no full page reloads
- **Tasks** — title, description, status, priority, due date, tags, project
- **Projects** — group tasks by repo or area of work, each with a color
- **Smart sorting** — blocked → in progress → todo → done, then by priority and due date
- **Filters** — by status, priority, project, and tag (all combinable)
- **Search** — debounced full-text across title and description
- **Overdue badges** — red highlight when a task is past its due date
- **Status toggle** — click the circle on any task to cycle todo → in progress → done
- **Keyboard shortcuts** — `N` new task, `/` search, `Esc` clear filters

## Getting Started

**Requirements:** Elixir 1.14+, Erlang/OTP 25+ (install via `brew install elixir`)

```bash
git clone https://github.com/jehualli/devtodo
cd devtodo

# Install deps, create DB, run migrations, seed sample data, build assets
mix setup

# Start the server
mix phx.server
```

Open [http://localhost:4000](http://localhost:4000).

## Data Model

```
Project
  name, description, color

Task
  title, description
  status:   todo | in_progress | blocked | done
  priority: low | medium | high | urgent
  due_date, tags[], project_id
```

## Tech Stack

| Layer    | Technology                  |
|----------|-----------------------------|
| Language | Elixir 1.14+                |
| Web      | Phoenix 1.7 + LiveView 1.0  |
| Database | SQLite via ecto_sqlite3      |
| CSS      | Tailwind CSS (dark theme)    |
| Server   | Bandit                       |

## Development

```bash
mix phx.server        # start with live reload
mix ecto.reset        # drop, recreate, migrate, and reseed
mix test              # run tests
```
