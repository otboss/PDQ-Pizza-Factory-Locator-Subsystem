# PizzaFactoryLocator

This application is the finished product of the Pizza Delivered Quickly Factory Locator Subsystem. This module has been compiled to erlang byte code for windows and unix-like operating systems. Provided below is the documentation on how to use this module.
<br>
<br>
Reference: https://people.uwec.edu/sulzertj/Teaching/is455/Resources/PizzaDeliveryQuickly_Case_Study.pdf
<br>
Module Documentation
<br>
<br>
1. Update Configuration
<br>
Run the following within the project directory. Enter the corresponding information to your mongo database.
<br>
mongo_database_address - The IP address of the Mongo Database server
mongo_database_username - The Auth Username of the Mongo Database server
mongo_database_password - The Auth Password of the Mongo Database server
mongo_database_port - The port number of the Mongo Database Server
orders_collection_name - The name given to the collection used to store pizza orders
<br>
<br>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval """
PizzaFactoryLocator.set_config(
  [mongo_database_address],
  [mongo_database_username],
  [mongo_database_password],
  [mongo_database_port],
  [orders_collection_name],
  [factories_collection_name],
  [latitude_field_name],
  [longitude_field_name]
)
""";
<br>
<br>
2. Get the current configuration
This command reads the configuration from file and prints it to the console
<br>
<br>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval """
{:ok, config} = PizzaFactoryLocator.get_config()
{:ok, config} = config |> Map.from_struct() |> Jason.encode()
IO.puts(config)
""";
<br>
<br>
3. Determine new Pizza Factory Location
Reads all the Pizza Orders from the database and, using the coordinates for each order, calculates the ideal location to place a new pizza factory.
<br>
<br>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval """
Application.ensure_all_started(:mongodb)
Database.connect()
PizzaFactoryLocator.determine_new_factory_location() |> IO.inspect()
""";
<br>
<br>
4. Save Factory
Saves a Factory to the database.
<br>
<br>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval """
Application.ensure_all_started(:mongodb)
Database.connect()
{:ok, coordinates} = Coordinates.constructor(
  [x_coordinate],
  [y_coordinate]
)
{:ok, factory} = Factory.constructor(
  [factory_name],
  coordinates,
  [phone_number],
)
Database.save_factory(factory)
""";
<br>
<br>
5. Get nearest factory
Gets the nearest factory to supplied coordinates. Takes an optional radius parameter measured in kilometers.
<br>
<br>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval """
Application.ensure_all_started(:mongodb)
Database.connect()
{:ok, coordinates} = Coordinates.constructor(
  [x_coordinate],
  [y_coordinate]
)
{:ok, factory} = Database.get_closest_factory(
  coordinates, [radius] #optional
)
factory |> Map.from_struct() |> Jason.encode() |> IO.puts()
""";

