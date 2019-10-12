defmodule FactoryLocator do
  @moduledoc """

  """
  @base_process_count Process.list() |> length()
  # Set the process limit based on the max available resources of the host machine
  @process_limit 1000
  @file_path "./output/best_new_factory_locations.txt"

  @doc """
  Parses large order and traffic dataset stored in the database and using as much
  of the host machine's resources as possible, calculates the top ten locations
  to construct a new pizza factory.
  """
  def determine_new_factory_location do
    order_cnt = Database.get_order_count()
    chunk_size = 1000

    chunks =
      (order_cnt / chunk_size)
      |> Float.ceil()
      |> to_string()
      |> Integer.parse()
      |> elem(0)

    Enum.each(0..chunks, fn x ->
      orders = Database.get_orders(chunk_size * x, chunk_size * x + chunk_size)

      Enum.each(orders, fn order ->
        spawn(fn ->
          {:ok, current_results} = File.read!(@file_path) |> Jason.decode()
          # TODO: implement the location finding algorithm here
          # the output result should be a list of the top ten
          # best coordinates to place a new factory by calculate
          # the midpoint of all the coordinates. A version of this
          # function in the future will account for road traffic
          # during operating hours
          {:ok, current_results} = Jason.encode(current_results)
          File.write!(@file_path, current_results)
        end)

        throttler()
      end)
    end)
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
end
