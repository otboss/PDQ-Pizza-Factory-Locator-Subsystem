defmodule Configuration do
  defstruct mongo_address: nil,
            mongo_database: nil,
            mongo_username: nil,
            mongo_password: nil,
            mongo_port: nil,
            orders_collection: nil,
            factories_collection: nil

  def constructor(
        mongo_address,
        mongo_database,
        mongo_username,
        mongo_password,
        mongo_port,
        orders_collection,
        factories_collection
      )
      when is_bitstring(mongo_address) and
             is_bitstring(mongo_database) and
             is_bitstring(mongo_password) and
             is_integer(mongo_port) and
             is_bitstring(orders_collection) and
             is_bitstring(factories_collection) do
    !is_nil(mongo_username) &&
      (is_bitstring(mongo_username) || raise "invalid mongo username provided")

    {:ok,
     %Configuration{
       :mongo_address => mongo_address,
       :mongo_username => mongo_username,
       :mongo_database => mongo_database,
       :mongo_password => mongo_password,
       :mongo_port => mongo_port,
       :orders_collection => orders_collection,
       :factories_collection => factories_collection
     }}
  end
end
