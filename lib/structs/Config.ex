defmodule Config do
  defstruct mongo_address: nil,
            mongo_username: nil,
            mongo_password: nil,
            mongo_port: nil,
            order_collection: nil,
            latitude_field: nil,
            longitude_field: nil

  def constructor(
        mongo_address,
        mongo_username,
        mongo_password,
        mongo_port,
        order_collection,
        latitude_field,
        longitude_field
      )
      when is_bitstring(mongo_address) and
             is_bitstring(mongo_username) and
             is_bitstring(mongo_password) and
             is_bitstring(mongo_port) and
             is_bitstring(order_collection) and
             is_bitstring(latitude_field) and
             is_bitstring(longitude_field) do
    {:ok,
     %Config{
       :mongo_address => mongo_address,
       :mongo_username => mongo_username,
       :mongo_password => mongo_password,
       :mongo_port => mongo_port,
       :order_collection => order_collection,
       :latitude_field => latitude_field,
       :longitude_field => longitude_field
     }}
  end
end