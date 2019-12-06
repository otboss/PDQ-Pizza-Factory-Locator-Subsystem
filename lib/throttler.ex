defmodule Throttler do
  @moduledoc """
  Limits the amount of running processes in order to prevent the host machine from crashing.
  """

  @doc """
  This function checks if the current number of processes exceeds the process_limit and stops
  the host machine from spawning new processes by calling itself recursively.
  """
  def throttle(max_process_count) when is_integer(max_process_count) do
    if Process.list() |> length >= max_process_count do
      Process.sleep(300)
      throttle(max_process_count)
    end
  end
end
