defmodule Coordinates do
  defstruct x: nil,
            y: nil

  def constructor(x, y) when is_float(x) and is_float(y) do
    {:ok,
     %Coordinates{
       :x => x,
       :y => y
     }}
  end
end
