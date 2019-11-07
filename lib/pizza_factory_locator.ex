defmodule PizzaFactoryLocator do
  @moduledoc """
  Module containing the main functionality of the project, that is the
  "determine_new_factory_location" function. This function should be exposed
  via a command-line API at deployment so that it can be intergrated into other
  projects
  """

  # The number of processes upon virtual machine boot
  # @base_process_count Process.list() |> length()
  # Set the process limit based on the max available resources of the host machine
  # @process_limit 1_000_000
  # Limits the amount of factories the app can read from the database at any one
  # moment in time. Set the chunk size based on the available RAM of the host machine
  @chunk_size 10000
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
      config["mongo_database"],
      config["mongo_username"],
      config["mongo_password"],
      config["mongo_port"],
      config["orders_collection"],
      config["factories_collection"]
    )
  end

  @doc """
  Writes the configuration from file
  """
  def set_config(
        mongo_address,
        mongo_database,
        mongo_username,
        mongo_password,
        mongo_port,
        order_collection,
        factories_collection,
        latitude_field,
        longitude_field
      )
      when is_bitstring(mongo_address) and
             is_bitstring(mongo_database) and
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
        mongo_database,
        mongo_username,
        mongo_password,
        mongo_port,
        order_collection,
        factories_collection
      )

    {:ok, config} = Map.from_struct(config) |> Jason.encode()
    File.write!(@config_directory, config)
  end

  @doc """
  Parses large order and traffic dataset stored in the database to calculate
  the best location for a new pizza factory using as much of the host machine's
  resources as possible. A version of this function in the future will account
  for road traffic during operating hours. Visit the following url for
  mathematical assistance:
  https://stackoverflow.com/questions/6671183/calculate-the-center-point-of-multiple-latitude-longitude-coordinate-pairs
  """
  def determine_new_factory_location(boundary_start \\ nil, boundary_stop \\ nil) do
    {:ok, order_cnt} = Database.get_order_count()

    if !is_nil(boundary_start) or !is_nil(boundary_stop) do
      if is_map(boundary_start) do
        boundary_start.__struct__ == Coordinates ||
          raise("Invalid boundary start provided")
      else
        raise("Invalid boundary start provided")
      end

      if is_map(boundary_stop) do
        boundary_stop.__struct__ == Coordinates ||
          raise("Invalid boundary stop provided")
      else
        raise("Invalid boundary stop provided")
      end
    end

    thread_chunk_size = (order_cnt / System.schedulers_online()) |> ceil()

    try do
      :ets.new(:buckets_registry, [:named_table, :set, :public])
    rescue
      _ ->
        nil
    end

    # Initialize old_value and new_value to a random number
    Enum.each([@old_value, @new_value], fn value ->
      :ets.insert(
        :buckets_registry,
        {value, Enum.random(1..(:math.pow(2, 256) |> ceil()))}
      )
    end)

    memory_coordinators =
      Enum.reduce(0..(System.schedulers_online() - 1), [], fn _, acc ->
        {:ok, mem_coord_pid} = MemoryCoordinator.start_link()
        acc ++ [mem_coord_pid]
      end)

    Enum.each(0..(System.schedulers_online() - 1), fn thread ->
      spawn(fn ->
        range_start = thread_chunk_size * thread
        range_stop = thread_chunk_size * thread + thread_chunk_size
        mem_coord_pid = Enum.at(memory_coordinators, thread)

        range_stop =
          (((range_stop - thread_chunk_size) / thread_chunk_size) |> floor() ==
             System.schedulers_online() - 1 && range_stop) || range_stop - 1

        Enum.reduce_while(
          range_start..range_stop,
          0,
          fn _, acc ->
            if acc <= range_stop,
              do:
                (fn ->
                   {:ok, orders} =
                     (!is_nil(boundary_start) && !is_nil(boundary_stop) &&
                        Database.get_orders(
                          acc,
                          acc + @chunk_size,
                          boundary_start,
                          boundary_stop
                        )) ||
                       Database.get_orders(acc, acc + @chunk_size)

                   Enum.each(orders, fn order ->
                     # Generates and stores a random integer globally. It is very unlikely that
                     # the same number will repeat. If "new_value" remains unchanged after x seconds
                     # then the program will assume that all orders have been processed and finalize
                     :ets.insert(
                       :buckets_registry,
                       {@new_value, Enum.random(1..(:math.pow(2, 256) |> ceil()))}
                     )

                     current_results = MemoryCoordinator.get_result(mem_coord_pid)

                     lat = order.coordinates.x * :math.pi() / 180
                     lon = order.coordinates.y * :math.pi() / 180

                     current_results = [
                       Enum.at(current_results, 0) + :math.cos(lat) * :math.cos(lon),
                       Enum.at(current_results, 1) + :math.cos(lat) * :math.sin(lon),
                       Enum.at(current_results, 2) + :math.sin(lat)
                     ]

                     MemoryCoordinator.update_result(mem_coord_pid, current_results)
                   end)

                   {:cont, acc + @chunk_size}
                 end).(),
              else: {:halt, acc}
          end
        )
      end)
    end)

    # Since all the functions are being processed concurrently a function
    # will be needed to pause until all orders have been processed.
    # This function call pauses the return until all orders have been processed.
    checker()

    result =
      Enum.reduce(0..(length(memory_coordinators) - 1), [0.0, 0.0, 0.0], fn x, acc ->
        pid = Enum.at(memory_coordinators, x)
        thread_result = MemoryCoordinator.get_result(pid)

        _acc = [
          Enum.at(acc, 0) + Enum.at(thread_result, 0),
          Enum.at(acc, 1) + Enum.at(thread_result, 1),
          Enum.at(acc, 2) + Enum.at(thread_result, 2)
        ]
      end)

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

  @doc """
  Calculates the shortest distance between the current location (origin) and a
  factory. Visit the following URL for mathematical assistance:
  https://www.mathwarehouse.com/algebra/distance_formula/index.php
  """
  def get_closest_factory(origin) when is_map(origin) do
    origin.__struct__ == Coordinates ||
      raise "Invalid origin provided"

    {:ok, factory_cnt} = Database.get_factory_count()
    thread_chunk_size = (factory_cnt / System.schedulers_online()) |> ceil()

    try do
      :ets.new(:buckets_registry, [:named_table, :set, :public])
    rescue
      _ ->
        nil
    end

    # Initialize old_value and new_value to a random number
    Enum.each([@old_value, @new_value], fn value ->
      :ets.insert(
        :buckets_registry,
        {value, Enum.random(1..(:math.pow(2, 256) |> ceil()))}
      )
    end)

    memory_coordinators =
      Enum.reduce(0..(System.schedulers_online() - 1), [], fn _, acc ->
        {:ok, mem_coord_pid} = MemoryCoordinator.start_link()
        acc ++ [mem_coord_pid]
      end)

    Enum.each(0..(System.schedulers_online() - 1), fn thread ->
      spawn(fn ->
        range_start = thread_chunk_size * thread
        range_stop = thread_chunk_size * thread + thread_chunk_size
        mem_coord_pid = Enum.at(memory_coordinators, thread)

        range_stop =
          (((range_stop - thread_chunk_size) / thread_chunk_size) |> floor() ==
             System.schedulers_online() - 1 && range_stop) || range_stop - 1

        Enum.reduce_while(range_start..range_stop, 0, fn _, acc ->
          if acc <= range_stop,
            do:
              {:cont,
               (fn ->
                  {:ok, factories} =
                    Database.get_factories(
                      acc,
                      acc + @chunk_size
                    )

                  Enum.each(factories, fn factory ->
                    :ets.insert(
                      :buckets_registry,
                      {@new_value, Enum.random(1..(:math.pow(2, 256) |> ceil()))}
                    )

                    current_result = MemoryCoordinator.get_closest_factory(mem_coord_pid)

                    distance =
                      :math.sqrt(
                        :math.pow(origin.x - factory.coordinates.x, 2) +
                          :math.pow(origin.y - factory.coordinates.y, 2)
                      )

                    (current_result == [] &&
                       MemoryCoordinator.update_closest_factory(mem_coord_pid, [
                         factory,
                         distance
                       ])) ||
                      (current_result |> Enum.at(1) > distance &&
                         MemoryCoordinator.update_closest_factory(mem_coord_pid, [
                           factory,
                           distance
                         ]))
                  end)

                  {:cont, acc + @chunk_size}
                end).()},
            else: {:halt, acc}
        end)
      end)
    end)

    # Since all the functions are being processed concurrently a function
    # will be needed to pause until all orders have been processed.
    # This function call pauses the return until all orders have been processed.
    checker()

    try do
      Enum.reduce(0..(length(memory_coordinators) - 1), [], fn thread, acc ->
        _acc =
          (thread == 0 &&
             MemoryCoordinator.get_closest_factory(Enum.at(memory_coordinators, thread))) ||
            (MemoryCoordinator.get_closest_factory(Enum.at(memory_coordinators, thread))
             |> Enum.at(1) < Enum.at(acc, 1) &&
               MemoryCoordinator.get_closest_factory(Enum.at(memory_coordinators, thread))) || acc
      end)
    rescue
      _ -> nil
    end
  end

  # Limits the amount of running processes in order to prevent the host machine from crashing.
  # This function checks if the current number of processes exceeds the process_limit and stops
  # the host machine from spawning new processes by calling itself recursively.
  # defp throttler do
  #   (Process.list() |> length()) - @base_process_count >= @process_limit &&
  #     (
  #       Process.sleep(300)
  #       throttler()
  #     )
  # end

  defp checker do
    old_value = :ets.lookup(:buckets_registry, @old_value) |> Enum.at(0) |> elem(1)
    new_value = :ets.lookup(:buckets_registry, @new_value) |> Enum.at(0) |> elem(1)

    old_value == new_value ||
      (
        Process.sleep(1000)

        :ets.insert(
          :buckets_registry,
          {@old_value, new_value}
        )

        # Loop until "new_value" is unchanged. If this is the case then the processing
        # is complete.
        checker()
      )
  end

  @doc """
  Shared memory. Prevents concurrent processes from writing to shared memory
  simultaneously by using locking
  """
  def memory_coordinator do
    try do
      :ets.new(:shared_memory_registry, [:named_table, :set, :protected])

      :ets.insert(
        :shared_memory_registry,
        {@current_results, [0.0, 0.0, 0.0]}
      )
    rescue
      _ -> nil
    end

    receive do
      result ->
        :ets.insert(
          :shared_memory_registry,
          {@current_results, result}
        )
    end

    memory_coordinator()
  end
end
