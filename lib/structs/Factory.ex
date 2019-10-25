defmodule Factory do
  defstruct name: nil,
            coordinates: nil,
            phone: nil

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
         coordinates: coordinates,
         phone: phone
       }}
    rescue
      x -> {:error, x}
    end
  end
end
