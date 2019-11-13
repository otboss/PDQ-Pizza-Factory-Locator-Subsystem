defmodule Coordinates do
  defstruct x: nil,
            y: nil

  def constructor(x, y) when is_number(x) and is_number(y) do
    {:ok,
     %Coordinates{
       :x => x,
       :y => y
     }}
  end
end
