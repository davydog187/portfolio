# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :portfolio,
  ecto_repos: [Portfolio.Repo]

# Configures the endpoint
config :portfolio, PortfolioWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "o00MMbXcBZ33+C0Ihwe2Ibftpu+SP4JhjFnKm9VcVrjXrEHF181UT93OaYd1Dkne",
  render_errors: [view: PortfolioWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Portfolio.PubSub,
  live_view: [signing_salt: "203CaLoJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
