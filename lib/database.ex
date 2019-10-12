defmodule Database do
  @moduledoc """
  The mongodb Database API module. All communication to the database should be done
  through this module.
  """

  def get_order_count() do
    0
  end

  @doc """
  Fetches orders from the database
  """
  def get_orders(
        start_index,
        stop_index,
        # OPTTIONAL: Get orders from a particular area
        zone_coordinates_start \\ nil,
        zone_coordinates_stop \\ nil
      )
      when is_integer(start_index) and is_integer(stop_index) do
    if zone_coordinates_start != nil && zone_coordinates_stop != nil do
      if zone_coordinates_start.__struct__ == Coordinates &&
           zone_coordinates_stop.__struct__ == Coordinates do
        # Fetch orders within a particular zone
      else
        raise "invalid zone provided"
      end
    else
      # Fetch all orders
    end
  end
end
