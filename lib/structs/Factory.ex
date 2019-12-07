defmodule Factory do
  @moduledoc """
  Provides methods for structuring factory details that are relevant to this subsystem
  """
  defstruct name: nil,
            coordinates: nil,
            phone: nil

  @doc """
  The Factory constructor function, returns Factory struct
  """
  def constructor(name, coordinates, phone)
      when is_bitstring(name) and
             is_map(coordinates) and
             is_integer(phone) do
    try do
      coordinates.__struct__ == Coordinates ||
        raise "invalid coordinates provided"

      {:ok,
       %Factory{
         name: name,
         coordinates: coordinates |> Map.from_struct(),
         phone: phone
       }}
    rescue
      x -> {:error, x}
    end
  end
end
