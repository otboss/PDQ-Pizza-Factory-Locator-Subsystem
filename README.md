# PizzaFactoryLocator

This application is the finished product of the Pizza Delivered Quickly Factory Locator Subsystem. This module has been compiled to erlang byte code for windows and unix-like operating systems. Provided below is the documentation on how to use this module.
<br>
<br>
Reference: https://people.uwec.edu/sulzertj/Teaching/is455/Resources/PizzaDeliveryQuickly_Case_Study.pdf
<br>
<br>
<h2>Command Line API</h2>
<h3>1. Update Configuration</h3>
<br>
Run the following within the project directory. Enter the corresponding information of the mongo database server.
<br>
<br>
<pre>
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
</pre>
<br>
<br>
mongo_database_address - The IP address of the Mongo Database server
<br>
mongo_database_username - The Auth Username of the Mongo Database server
<br>
mongo_database_password - The Auth Password of the Mongo Database server
<br>
mongo_database_port - The port number of the Mongo Database Server
<br>
orders_collection_name - The name given to the collection used to store pizza orders
<br>
factories_collection_name - The name given to the collection used to store factories
<br>
latitude_field_name - The name of the latitude field within each collection document
<br>
longitude_field_name - The name of the longitude field within each collection document
<br>
<br>
<h3>2. Get the current configuration</h3>
This command reads the configuration from file and prints it to the console
<br>
<br>
<pre>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval """
{:ok, config} = PizzaFactoryLocator.get_config()
{:ok, config} = config |> Map.from_struct() |> Jason.encode()
IO.puts(config)
""";
</pre>
<br>
<br>
<h3>3. Determine new Pizza Factory Location</h3>
Reads all the Pizza Orders from the database and, using the coordinates for each order, calculates the ideal location to place a new pizza factory.
<br>
<br>
<pre>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval """
Application.ensure_all_started(:mongodb)
Database.connect()
PizzaFactoryLocator.determine_new_factory_location() |> IO.inspect()
""";
</pre>
<br>
<br>
<h3>4. Save Factory</h3>
Saves a Factory to the database.
<br>
<br>
<pre>
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
</pre>
<br>
<br>
x_coordinate - The x coordinate of the factory
<br>
y_coordinate - The y coordinate of the factory
<br>
factory_name - The name of the factory
<br>
phone_number - The phone number of the factory
<br>
<br>
<br>
<h3>5. Get nearest factory</h3>
Gets the nearest factory to supplied coordinates. Takes an optional area parameter measured in kilometers.
<br>
<br>
<pre>
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
</pre>
<br>
<br>
x_coordinate - The x coordinate of the origin
<br>
y_coordinate - The y coordinate of the origin
<br>
radius - The search area in kilometers
