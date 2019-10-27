defmodule PizzaFactoryLocator do
  @moduledoc """
  Module containing the main functionality of the project, that is the
  "determine_new_factory_location" function. This function should be exposed
  via a command-line API at deployment so that it can be intergrated into other
  projects
  """

  # The number of processes upon virtual machine boot
  @base_process_count Process.list() |> length()
  # Set the process limit based on the max available resources of the host machine
  @process_limit 1000
  # Set the chunk size based on the available RAM of the host machine
  @chunk_size 1000
  @result_file "./output/final_result.json"
  @new_value "new_value"
  @old_value "old_value"
  @current_results "current_results"
  @config_directory "./config/config.json"

  @doc """
  Reads the configuration from file
  """
  def get_config() do
    {:ok, config} = File.read(@config_directory)
    {:ok, config} = config |> String.replace("\n", "") |> Jason.decode()

    Configuration.constructor(
      config["mongo_address"],
      config["mongo_username"],
      config["mongo_password"],
      config["mongo_port"],
      config["orders_collection"],
      config["factories_collection"],
      config["latitude_field"],
      config["longitude_field"]
    )
  end

  @doc """
  Writes the configuration from file
  """
  def set_config(
        mongo_address,
        mongo_username,
        mongo_password,
        mongo_port,
        order_collection,
        factories_collection,
        latitude_field,
        longitude_field
      )
      when is_bitstring(mongo_address) and
             is_bitstring(mongo_username) and
             is_bitstring(mongo_password) and
             is_integer(mongo_port) and
             is_bitstring(order_collection) and
             is_bitstring(factories_collection) and
             is_bitstring(latitude_field) and
             is_bitstring(longitude_field) do
    {:ok, config} =
      Configuration.constructor(
        mongo_address,
        mongo_username,
        mongo_password,
        mongo_port,
        order_collection,
        factories_collection,
        latitude_field,
        longitude_field
      )

    {:ok, config} = Map.from_struct(config) |> Jason.encode()
    File.write(@config_directory, config)
  end

  @doc """
  Parses large order and traffic dataset stored in the database to calculate
  the best location for a new pizza factory using as much of the host machine's
  resources as possible. A version of this function in the future will account
  for road traffic during operating hours. Visit the following url for
  mathematical assistance:
  https://stackoverflow.com/questions/6671183/calculate-the-center-point-of-multiple-latitude-longitude-coordinate-pairs
  """
  def determine_new_factory_location do
    {:ok, order_cnt} = Database.get_order_count()

    chunks = (order_cnt / @chunk_size) |> ceil()

    :ets.new(:buckets_registry, [:named_table])

    :ets.insert(
      :buckets_registry,
      {@current_results, [0.0, 0.0, 0.0]}
    )

    # Initialize old_value and new_value to a random number
    Enum.each([@old_value, @new_value], fn value ->
      :ets.insert(
        :buckets_registry,
        {value, Enum.random(1..(:math.pow(2, 256) |> ceil()))}
      )
    end)

    Enum.each(0..chunks, fn x ->
      {:ok, orders} = Database.get_orders(@chunk_size * x, @chunk_size * x + @chunk_size)

      Enum.each(orders, fn order ->
        spawn(fn ->
          # Generates and stores a random integer globally. It is very unlikely that
          # the same number will repeat. If "new_value" remains unchanged after x seconds
          # then the program will assume that all orders have been processed and finalize
          :ets.insert(
            :buckets_registry,
            {@new_value, Enum.random(1..(:math.pow(2, 256) |> ceil()))}
          )

          current_results =
            :ets.lookup(:buckets_registry, @current_results) |> Enum.at(0) |> elem(1)

          lat = order.coordinates.x * :math.pi() / 180
          lon = order.coordinates.y * :math.pi() / 180

          current_results = [
            Enum.at(current_results, 0) + :math.cos(lat) * :math.cos(lon),
            Enum.at(current_results, 1) + :math.cos(lat) * :math.sin(lon),
            Enum.at(current_results, 2) + :math.sin(lat)
          ]

          :ets.insert(
            :buckets_registry,
            {@current_results, current_results}
          )
        end)

        throttler()
      end)
    end)

    # Since all the functions are being processed concurrently a function
    # will be needed to pause until all orders have been processed.
    # This function call pauses the return until all orders have been processed.
    checker()

    result = :ets.lookup(:buckets_registry, @current_results) |> Enum.at(0) |> elem(1)
    x = (result |> Enum.at(0)) / order_cnt
    y = (result |> Enum.at(1)) / order_cnt
    z = (result |> Enum.at(2)) / order_cnt
    lon = :math.atan2(y, x)
    hyp = :math.sqrt(x * x + y * y)
    lat = :math.atan2(z, hyp)
    result = [lat * 180 / :math.pi(), lon * 180 / :math.pi()]
    {:ok, result_json} = Jason.encode(result)
    File.write(@result_file, result_json)
    result
  end

  # Limits the amount of running processes in order to prevent the host machine from crashing.
  # This function checks if the current number of processes exceeds the process_limit and stops
  # the host machine from spawning new processes by calling itself recursively.
  defp throttler do
    (Process.list() |> length()) - @base_process_count >= @process_limit &&
      (
        Process.sleep(300)
        throttler()
      )
  end

  defp checker do
    old_value = :ets.lookup(:buckets_registry, @old_value) |> Enum.at(0) |> elem(1)
    new_value = :ets.lookup(:buckets_registry, @new_value) |> Enum.at(0) |> elem(1)

    old_value == new_value ||
      (
        Process.sleep(2000)

        :ets.insert(
          :buckets_registry,
          {@old_value, :ets.lookup(:buckets_registry, new_value)}
        )

        # Loop until "new_value" is unchanged. If this is the case then the processing
        # is complete.
        checker()
      )
  end
end
