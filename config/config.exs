# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :api_phx,
  ecto_repos: [ApiPhx.Repo]

# Configures the endpoint
config :api_phx, ApiPhxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SAE82H+jgRmXGqpWjXgLHsqtg97b1DFAvtQND859+yizWDQenV3gfzpxHg2wMhAl",
  render_errors: [view: ApiPhxWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ApiPhx.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
