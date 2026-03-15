alias Devtodo.Repo
alias Devtodo.Projects.Project
alias Devtodo.Tasks.Task

# Create sample projects
{:ok, api} = Repo.insert(%Project{name: "API", color: "#6366f1", description: "Backend API work"})
{:ok, frontend} = Repo.insert(%Project{name: "Frontend", color: "#ec4899", description: "UI and UX work"})
{:ok, infra} = Repo.insert(%Project{name: "Infra", color: "#22c55e", description: "DevOps and infrastructure"})

# Create sample tasks
today = Date.utc_today()

tasks = [
  %{
    title: "Review PR: Add rate limiting to auth endpoints",
    description: "Check the implementation in feature/rate-limit branch",
    status: :in_progress,
    priority: :high,
    due_date: Date.add(today, 1),
    tags: ["api", "security", "review"],
    project_id: api.id
  },
  %{
    title: "Fix N+1 query on /users index",
    description: "Users endpoint loads associations in a loop. Add preload.",
    status: :todo,
    priority: :urgent,
    due_date: today,
    tags: ["bug", "performance", "api"],
    project_id: api.id
  },
  %{
    title: "Update dashboard chart library to v3",
    description: "Breaking changes in v3 need component rewrites",
    status: :blocked,
    priority: :medium,
    tags: ["frontend", "dependency"],
    project_id: frontend.id
  },
  %{
    title: "Write unit tests for auth module",
    description: "Coverage is at 43%, need to get to 80%",
    status: :todo,
    priority: :high,
    due_date: Date.add(today, 5),
    tags: ["testing", "api"],
    project_id: api.id
  },
  %{
    title: "Set up CI/CD pipeline for staging",
    description: "GitHub Actions workflow for auto-deploy to staging on merge to main",
    status: :in_progress,
    priority: :high,
    tags: ["devops", "ci"],
    project_id: infra.id
  },
  %{
    title: "Document REST API endpoints",
    description: "OpenAPI/Swagger spec is outdated. Update with new endpoints.",
    status: :todo,
    priority: :medium,
    tags: ["docs", "api"],
    project_id: api.id
  },
  %{
    title: "Refactor auth middleware to use JWT",
    description: "Current session-based auth needs to be replaced with JWT for mobile support",
    status: :todo,
    priority: :high,
    due_date: Date.add(today, 14),
    tags: ["refactor", "auth", "api"],
    project_id: api.id
  },
  %{
    title: "Implement dark mode toggle",
    status: :done,
    priority: :low,
    tags: ["frontend", "ux"],
    project_id: frontend.id
  },
  %{
    title: "Upgrade Postgres to 16",
    description: "EOL approaching for pg14. Test migration on staging first.",
    status: :todo,
    priority: :medium,
    due_date: Date.add(today, 30),
    tags: ["database", "devops"],
    project_id: infra.id
  },
  %{
    title: "Read Elixir in Action Ch. 8-10",
    status: :todo,
    priority: :low,
    tags: ["learning"]
  }
]

for attrs <- tasks do
  Repo.insert!(%Task{
    title: attrs.title,
    description: Map.get(attrs, :description),
    status: attrs.status,
    priority: attrs.priority,
    due_date: Map.get(attrs, :due_date),
    tags: Map.get(attrs, :tags, []),
    project_id: Map.get(attrs, :project_id)
  })
end

IO.puts("Seeded #{length(tasks)} tasks across 3 projects")
