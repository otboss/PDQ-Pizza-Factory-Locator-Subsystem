defmodule Database do
  @moduledoc """
  The mongodb Database API module. All communication to the database should be done
  through this module.
  """

  @doc """
  Gets the number of orders from the database
  """
  def get_order_count() do
    try do
      {:ok, config} = FactoryLocator.Application.get_config()

      Mongo.count_documents(
        :db_connection,
        config.orders_collection,
        %{}
      )
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
      {:ok, config} = FactoryLocator.Application.get_config()

      if is_map(zone_coordinates_start) && is_map(zone_coordinates_stop) do
        if zone_coordinates_start.__struct__ == Coordinates &&
             zone_coordinates_stop.__struct__ == Coordinates do
          # Fetch orders within a particular zone using Mongo driver
          {:ok,
           Mongo.find(:db_connection, config.orders_collection, %{
             "$slice": [start_index, stop_index - start_index],
             "$and": [
               %{"#{config.latitude_field}": %{"$gte": zone_coordinates_start.x}},
               %{"#{config.longitude_field}": %{"$lte": zone_coordinates_start.y}},
               %{"#{config.latitude_field}": %{"$lte": zone_coordinates_stop.x}},
               %{"#{config.longitude_field}": %{"$gte": zone_coordinates_stop.y}}
             ]
           })
           |> Enum.to_list()
           |> Enum.map(fn order_json ->
             {:ok, coordinates} =
               Coordinates.constructor(
                 order_json[config.latitude_field],
                 order_json[config.longitude_field]
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
         Mongo.find(:db_connection, config.orders_collection, %{
           "$slice": [start_index, stop_index - start_index]
         })
         |> Enum.to_list()
         |> Enum.map(fn order_json ->
           {:ok, coordinates} =
             Coordinates.constructor(
               order_json[config.latitude_field],
               order_json[config.longitude_field]
             )

           {:ok, order} = Order.constructor(coordinates)
           order
         end)}
      end
    rescue
      x -> {:error, x}
    end
  end
end
