defmodule Coordinates do
  @moduledoc """
  Provides methods for structuring latitude and longitude coordinate pairs
  """
  defstruct x: nil,
            y: nil

  @doc """
  Coordinates constructor function, returns Coordinates struct
  """
  def constructor(x, y) when is_number(x) and is_number(y) do
    {:ok,
     %Coordinates{
       :x => x,
       :y => y
     }}
  end
end
