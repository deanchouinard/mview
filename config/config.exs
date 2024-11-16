# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :dwiki, DwikiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sCJO8Twq5bFXq6ASxpK4cSbywg88Ten62bnqMGryE7jhfuqgfBm6Mf7eN8zwV7xF",
  render_errors: [view: DwikiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dwiki.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
