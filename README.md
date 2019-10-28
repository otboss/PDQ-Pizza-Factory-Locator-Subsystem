# PizzaFactoryLocator

This application is the finished product of the Pizza Delivered Quickly Factory Locator Subsystem. This module has been compiled to erlang byte code for windows and unix-like operating systems. Provided below is the documentation on how to use this module.
<br>
<br>
Reference: https://people.uwec.edu/sulzertj/Teaching/is455/Resources/PizzaDeliveryQuickly_Case_Study.pdf
<br>
<br>
<h2>Command Line API Documentation</h2>
Run the following commands within the project directory's root.
<br>
<br>
<h3>1. Set Configuration</h3>
<br>
Updates the configuration. Enter the corresponding information of the mongo database server.
<br>
<br>
<pre>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval '''
PizzaFactoryLocator.set_config(
  <i>[mongo_database_address]</i>,
  <i>[mongo_database_username]</i>,
  <i>[mongo_database_password]</i>,
  <i>[mongo_database_port]</i>,
  <i>[orders_collection_name]</i>,
  <i>[factories_collection_name]</i>,
  <i>[latitude_field_name]</i>,
  <i>[longitude_field_name]</i>
)
''';
</pre>
<h4>Parameters</h4>
<ul>
  <li>mongo_database_address - The IP address of the Mongo Database server</li>
  <li>mongo_database_username - The Auth Username of the Mongo Database server</li>
  <li>mongo_database_password - The Auth Password of the Mongo Database server</li>
  <li>mongo_database_port - The port number of the Mongo Database Server</li>
  <li>orders_collection_name - The name given to the collection used to store pizza orders</li>
  <li>factories_collection_name - The name given to the collection used to store factories</li>
  <li>latitude_field_name - The name of the latitude field within each collection document</li>
  <li>longitude_field_name - The name of the longitude field within each collection document</li>
</ul>
<br>
<br>
<h3>2. Get Configuration</h3>
This command reads the configuration from file and prints it to the console.
<br>
<br>
<pre>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval '''
{:ok, config} = PizzaFactoryLocator.get_config()
{:ok, config} = config |> Map.from_struct() |> Jason.encode()
IO.puts(config)
''';
</pre>
<br>
<br>
<h3>3. Determine New Pizza Factory Location</h3>
Reads all the Pizza Orders from the database and, using the coordinates for each order, calculates the ideal location to place a new pizza factory.
<br>
<br>
<pre>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval '''
Application.ensure_all_started(:mongodb)
{:ok, _} = Database.connect()
PizzaFactoryLocator.determine_new_factory_location() |> IO.inspect()
''';
</pre>
<br>
<br>
<h3>4. Save Factory</h3>
Saves a Factory to the database.
<br>
<br>
<pre>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval '''
Application.ensure_all_started(:mongodb)
{:ok, _} = Database.connect()
{:ok, coordinates} = Coordinates.constructor(
  <i>[x_coordinate]</i>,
  <i>[y_coordinate]</i>
)
{:ok, factory} = Factory.constructor(
  <i>[factory_name]</i>,
  coordinates,
  <i>[phone_number]</i>,
)
{:ok, _} = Database.save_factory(factory)
''';
</pre>
<h4>Parameters</h4>
<ul>
  <li>x_coordinate - The x coordinate of the factory</li>
  <li>y_coordinate - The y coordinate of the factory</li>
  <li>factory_name - The name of the factory</li>
  <li>phone_number - The phone number of the factory</li>
</ul>
<br>
<br>
<br>
<h3>5. Get Closest Factory</h3>
Gets the nearest factory to supplied coordinates. Takes an optional max radius parameter measured in kilometers.
<br>
<br>
<pre>
_build/prod/rel/pizza_factory_locator/bin/pizza_factory_locator eval '''
Application.ensure_all_started(:mongodb)
{:ok, _} = Database.connect()
{:ok, coordinates} = Coordinates.constructor(
  <i>[x_coordinate]</i>,
  <i>[y_coordinate]</i>
)
{:ok, factory} = Database.get_closest_factory(
  coordinates #optional,<i>[max_radius]</i> 
)
{:ok, factory} = factory |> Map.from_struct() |> Jason.encode()
IO.puts(factory)
''';
</pre>
<h4>Parameters</h4>
<ul>
  <li>x_coordinate - The x coordinate of the origin</l1>
  <li>y_coordinate - The y coordinate of the origin</l1>
  <li>max_radius - The search area in kilometers</l1>
</ul>
