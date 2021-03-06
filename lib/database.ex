defmodule Database do
  @moduledoc """
  The mongodb Database API module. All communication to the database should be done
  through this module.
  """

  @doc """
  Attempts to connect to the Mongo Database using the configuration file
  """
  def connect() do
    {:ok, config} = PizzaFactoryLocator.get_config()

    (is_nil(config.mongo_username) &&
       ({:ok, _} =
          Mongo.start_link(
            name: :db_connection,
            hostname: config.mongo_address,
            database: config.mongo_database,
            port: config.mongo_port,
            pool_size: 2
          ))) ||
      ({:ok, _} =
         Mongo.start_link(
           name: :db_connection,
           hostname: config.mongo_address,
           database: config.mongo_database,
           port: config.mongo_port,
           username: config.mongo_username,
           password: config.mongo_password,
           pool_size: 2
         ))
  end

  @doc """
  Gets the number of orders from the database
  """
  def get_order_count() do
    try do
      {:ok, config} = PizzaFactoryLocator.get_config()
      Mongo.count_documents(:db_connection, config.orders_collection, %{})
    rescue
      x -> {:error, x}
    end
  end

  @doc """
  Gets the number of factories from the database
  """
  def get_factory_count() do
    try do
      {:ok, config} = PizzaFactoryLocator.get_config()
      Mongo.count_documents(:db_connection, config.factories_collection, %{})
    rescue
      x -> {:error, x}
    end
  end

  @doc """
  Fetches orders from the database. Returns an array of Order structs. Orders
  from a particular area may be fetched by passing zone parameters. Start coordinates
  indicate the top left of a geographical area while end coordinates indicate the
  bottom right.
  """
  def get_orders(
        start_index,
        stop_index,
        # OPTTIONAL: Get orders from a particular area
        zone_coordinates_start \\ nil,
        zone_coordinates_stop \\ nil
      )
      when is_integer(start_index) and is_integer(stop_index) do
    try do
      {:ok, config} = PizzaFactoryLocator.get_config()

      if is_map(zone_coordinates_start) && is_map(zone_coordinates_stop) do
        if zone_coordinates_start.__struct__ == Coordinates &&
             zone_coordinates_stop.__struct__ == Coordinates do
          # Fetch orders within a particular zone using Mongo driver
          {:ok,
           Mongo.find(
             :db_connection,
             config.orders_collection,
             %{
               "$and": [
                 %{"coordinates.x": %{"$gte": zone_coordinates_start.x}},
                 %{"coordinates.y": %{"$lte": zone_coordinates_start.y}},
                 %{"coordinates.x": %{"$lte": zone_coordinates_stop.x}},
                 %{"coordinates.y": %{"$gte": zone_coordinates_stop.y}}
               ]
             },
             skip: start_index,
             limit: stop_index - start_index
           )
           |> Enum.to_list()
           |> Enum.map(fn order_json ->
             {:ok, coordinates} =
               Coordinates.constructor(
                 order_json["coordinates"]["x"],
                 order_json["coordinates"]["y"]
               )

             {:ok, order} = Order.constructor(coordinates)
             order
           end)}
        else
          raise "invalid zone provided"
        end
      else
        # Fetch all orders within range using Mongo driver
        {:ok,
         Mongo.find(:db_connection, config.orders_collection, %{},
           skip: start_index,
           limit: stop_index - start_index
         )
         |> Enum.to_list()
         |> Enum.map(fn order_json ->
           try do
             {:ok, coordinates} =
               Coordinates.constructor(
                 order_json["coordinates"]["x"],
                 order_json["coordinates"]["y"]
               )

             {:ok, order} = Order.constructor(coordinates)
             order
           rescue
             _ -> nil
           end
         end)}
      end
    rescue
      x -> {:error, x}
    end
  end

  @doc """
  Gets a slice of factories from the database. The size of the slice and the region
  to fetch factories from can be specified as parameters
  """
  def get_factories(
        start_index,
        stop_index,
        # OPTTIONAL: Get factories from a particular area
        zone_coordinates_start \\ nil,
        zone_coordinates_stop \\ nil
      )
      when is_integer(start_index) and is_integer(stop_index) do
    try do
      {:ok, config} = PizzaFactoryLocator.get_config()

      if is_map(zone_coordinates_start) && is_map(zone_coordinates_stop) do
        if zone_coordinates_start.__struct__ == Coordinates &&
             zone_coordinates_stop.__struct__ == Coordinates do
          {:ok,
           Mongo.find(
             :db_connection,
             config.factories_collection,
             %{
               "$and": [
                 %{"coordinates.x": %{"$gte": zone_coordinates_start.x}},
                 %{"coordinates.y": %{"$lte": zone_coordinates_start.y}},
                 %{"coordinates.x": %{"$lte": zone_coordinates_stop.x}},
                 %{"coordinates.y": %{"$gte": zone_coordinates_stop.y}}
               ]
             },
             skip: start_index,
             limit: stop_index - start_index
           )
           |> Enum.to_list()
           |> Enum.map(fn factory_json ->
             try do
               {:ok, coordinates} =
                 Coordinates.constructor(
                   factory_json["coordinates"]["x"],
                   factory_json["coordinates"]["y"]
                 )

               {:ok, factory} =
                 Factory.constructor(
                   factory_json["name"],
                   coordinates,
                   factory_json["phone"]
                 )

               factory
             rescue
               _ ->
                 nil
             end
           end)}
        else
          raise "invalid zone provided"
        end
      else
        {:ok,
         Mongo.find(
           :db_connection,
           config.factories_collection,
           %{},
           skip: start_index,
           limit: stop_index - start_index
         )
         |> Enum.to_list()
         |> Enum.map(fn factory_json ->
           try do
             {:ok, coordinates} =
               Coordinates.constructor(
                 factory_json["coordinates"]["x"],
                 factory_json["coordinates"]["y"]
               )

             {:ok, factory} =
               Factory.constructor(
                 factory_json["name"],
                 coordinates,
                 factory_json["phone"]
               )

             factory
           rescue
             _ ->
               nil
           end
         end)}
      end
    rescue
      x ->
        {:error, x}
    end
  end

  @doc """
  Saves an order to the database
  """
  def save_order(order) when is_map(order) do
    try do
      {:ok, config} = PizzaFactoryLocator.get_config()

      order.__struct__ == Order ||
        raise "Invalid order provided"

      Mongo.insert_one(
        :db_connection,
        config.orders_collection,
        order |> Map.from_struct()
      )
    rescue
      x -> {:error, x}
    end
  end

  @doc """
  Saves a factory to the database
  """
  def save_factory(factory) when is_map(factory) do
    try do
      {:ok, config} = PizzaFactoryLocator.get_config()

      factory.__struct__ == Factory ||
        raise "invalid factory provided"

      Mongo.insert_one(
        :db_connection,
        config.factories_collection,
        factory |> Map.from_struct()
      )
    rescue
      x -> {:error, x}
    end
  end
end
