defmodule FactoryLocator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec
  @config_directory "./config/config.json"

  def start(_type, _args) do
    {:ok, config} = get_config()

    children = [
      # Starts a worker by calling: FactoryLocator.Worker.start_link(arg)
      # {FactoryLocator.Worker, arg}
      worker(Mongo, [
        [
          name: :db_connection,
          database: config["mongo_address"],
          port: config["port"],
          pool_size: 2,
          username: config["username"],
          password: config["password"]
        ]
      ])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FactoryLocator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_config() do
    {:ok, config} = File.read(@config_directory)
    Jason.decode(config)
  end

  def set_config(
        mongo_address,
        mongo_username,
        mongo_password,
        mongo_port,
        order_collection,
        latitude_field,
        longitude_field
      )
      when is_bitstring(mongo_address) and
             is_bitstring(mongo_username) and
             is_bitstring(mongo_password) and
             is_integer(mongo_port) and
             is_bitstring(order_collection) and
             is_bitstring(latitude_field) and
             is_bitstring(longitude_field) do
    {:ok, config} =
      Jason.encode(%{
        :mongo_address => mongo_address,
        :mongo_username => mongo_username,
        :mongo_password => mongo_password,
        :mongo_port => mongo_port,
        :order_collection => order_collection,
        :latitude_field => latitude_field,
        :longitude_field => longitude_field
      })

    File.write!(@config_directory, config)
  end
end
