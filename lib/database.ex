defmodule Database do
  @moduledoc """
  The mongodb Database API module. All communication to the database should be done
  through this module.
  """

  # @config FactoryLocator.Application.get_config() |> elem(1)

  def get_order_count() do
    try do
      # TODO: Implement order count function here using the Mongo driver
      {:ok, 0}
    rescue
      x -> {:error, x}
    end
  end

  @doc """
  Fetches orders from the database. Returns an array of Order structs.
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
      if zone_coordinates_start != nil && zone_coordinates_stop != nil do
        if zone_coordinates_start.__struct__ == Coordinates &&
             zone_coordinates_stop.__struct__ == Coordinates do
          # TODO: Fetch orders within a particular zone using Mongo driver
          {:ok, [%Order{}]}
        else
          raise "invalid zone provided"
        end
      else
        # TODO: Fetch all orders using Mongo driver
        {:ok, [%Order{}]}
      end
    rescue
      x -> {:error, x}
    end
  end
end
