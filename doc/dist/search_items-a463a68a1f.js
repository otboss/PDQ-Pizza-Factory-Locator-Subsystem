searchNodes=[{"ref":"Configuration.html","title":"Configuration","type":"module","doc":"Provides methods for structuring the JSON contents of the configuration file as a struct"},{"ref":"Configuration.html#constructor/7","title":"Configuration.constructor/7","type":"function","doc":"Configuration constructor function, returns Configuration struct"},{"ref":"Coordinates.html","title":"Coordinates","type":"module","doc":"Provides methods for structuring latitude and longitude coordinate pairs"},{"ref":"Coordinates.html#constructor/2","title":"Coordinates.constructor/2","type":"function","doc":"Coordinates constructor function, returns Coordinates struct"},{"ref":"Database.html","title":"Database","type":"module","doc":"The mongodb Database API module. All communication to the database should be done through this module."},{"ref":"Database.html#connect/0","title":"Database.connect/0","type":"function","doc":"Attempts to connect to the Mongo Database using the configuration file"},{"ref":"Database.html#get_factories/4","title":"Database.get_factories/4","type":"function","doc":"Gets a slice of factories from the database. The size of the slice and the region to fetch factories from can be specified as parameters"},{"ref":"Database.html#get_factory_count/0","title":"Database.get_factory_count/0","type":"function","doc":"Gets the number of factories from the database"},{"ref":"Database.html#get_order_count/0","title":"Database.get_order_count/0","type":"function","doc":"Gets the number of orders from the database"},{"ref":"Database.html#get_orders/4","title":"Database.get_orders/4","type":"function","doc":"Fetches orders from the database. Returns an array of Order structs. Orders from a particular area may be fetched by passing zone parameters. Start coordinates indicate the top left of a geographical area while end coordinates indicate the bottom right."},{"ref":"Database.html#save_factory/1","title":"Database.save_factory/1","type":"function","doc":"Saves a factory to the database"},{"ref":"Database.html#save_order/1","title":"Database.save_order/1","type":"function","doc":"Saves an order to the database"},{"ref":"Factory.html","title":"Factory","type":"module","doc":"Provides methods for structuring factory details that are relevant to this subsystem"},{"ref":"Factory.html#constructor/3","title":"Factory.constructor/3","type":"function","doc":"The Factory constructor function, returns Factory struct"},{"ref":"MemoryCoordinator.html","title":"MemoryCoordinator","type":"module","doc":"Stores state within a process of coordinate results used in the PizzaFactoryLocator.determine_new_factory_location and PizzaFactoryLocator.get_closest_factory funtions. This module aids in the parallel processing of pizza orders and factories by making use of the GenServer Module."},{"ref":"MemoryCoordinator.html#child_spec/1","title":"MemoryCoordinator.child_spec/1","type":"function","doc":"Returns a specification to start this module under a supervisor. See Supervisor."},{"ref":"MemoryCoordinator.html#get_closest_factory/1","title":"MemoryCoordinator.get_closest_factory/1","type":"function","doc":""},{"ref":"MemoryCoordinator.html#get_result/1","title":"MemoryCoordinator.get_result/1","type":"function","doc":""},{"ref":"MemoryCoordinator.html#init/1","title":"MemoryCoordinator.init/1","type":"function","doc":"Invoked when the server is started. start_link/3 or start/3 will block until it returns. init_arg is the argument term (second argument) passed to start_link/3. Returning {:ok, state} will cause start_link/3 to return {:ok, pid} and the process to enter its loop. Returning {:ok, state, timeout} is similar to {:ok, state}, except that it also sets a timeout. See the &quot;Timeouts&quot; section in the module documentation for more information. Returning {:ok, state, :hibernate} is similar to {:ok, state} except the process is hibernated before entering the loop. See c:handle_call/3 for more information on hibernation. Returning {:ok, state, {:continue, continue}} is similar to {:ok, state} except that immediately after entering the loop the c:handle_continue/2 callback will be invoked with the value continue as first argument. Returning :ignore will cause start_link/3 to return :ignore and the process will exit normally without entering the loop or calling c:terminate/2. If used when part of a supervision tree the parent supervisor will not fail to start nor immediately try to restart the GenServer. The remainder of the supervision tree will be started and so the GenServer should not be required by other processes. It can be started later with Supervisor.restart_child/2 as the child specification is saved in the parent supervisor. The main use cases for this are: The GenServer is disabled by configuration but might be enabled later. An error occurred and it will be handled by a different mechanism than the Supervisor. Likely this approach involves calling Supervisor.restart_child/2 after a delay to attempt a restart. Returning {:stop, reason} will cause start_link/3 to return {:error, reason} and the process to exit with reason reason without entering the loop or calling c:terminate/2. Callback implementation for GenServer.init/1."},{"ref":"MemoryCoordinator.html#start_link/0","title":"MemoryCoordinator.start_link/0","type":"function","doc":""},{"ref":"MemoryCoordinator.html#update_closest_factory/2","title":"MemoryCoordinator.update_closest_factory/2","type":"function","doc":""},{"ref":"MemoryCoordinator.html#update_result/2","title":"MemoryCoordinator.update_result/2","type":"function","doc":""},{"ref":"Order.html","title":"Order","type":"module","doc":"This struct formats order data. As far as the factory locator subsytem is concerned only the location/coordinates of each order is important."},{"ref":"Order.html#constructor/1","title":"Order.constructor/1","type":"function","doc":"The Order constructor function, returns an Order struct"},{"ref":"PizzaFactoryLocator.html","title":"PizzaFactoryLocator","type":"module","doc":"Module containing the main functionality of the project, that is the &quot;determine_new_factory_location&quot; function. This function should be exposed via a command-line API at deployment so that it can be intergrated into other projects"},{"ref":"PizzaFactoryLocator.html#determine_new_factory_location/2","title":"PizzaFactoryLocator.determine_new_factory_location/2","type":"function","doc":"Parses large order dataset stored in the database to calculate the best location for a new pizza factory using as much of the host machine&#39;s resources as possible. Future implementations of this function in the future can account for road traffic during operating hours for a more accurate result. Visit the following url for mathematical assistance: https://stackoverflow.com/questions/6671183/calculate-the-center-point-of-multiple-latitude-longitude-coordinate-pairs"},{"ref":"PizzaFactoryLocator.html#get_closest_factory/1","title":"PizzaFactoryLocator.get_closest_factory/1","type":"function","doc":"Calculates the shortest distance between the current location (origin) and a factory. Visit the following URL for mathematical assistance: https://www.mathwarehouse.com/algebra/distance_formula/index.php"},{"ref":"PizzaFactoryLocator.html#get_config/0","title":"PizzaFactoryLocator.get_config/0","type":"function","doc":"Reads the configuration from file"},{"ref":"PizzaFactoryLocator.html#set_config/9","title":"PizzaFactoryLocator.set_config/9","type":"function","doc":"Writes the configuration to file"},{"ref":"Throttler.html","title":"Throttler","type":"module","doc":"Limits the amount of running processes in order to prevent the host machine from crashing."},{"ref":"Throttler.html#throttle/1","title":"Throttler.throttle/1","type":"function","doc":"This function checks if the current number of processes exceeds the process_limit and stops the host machine from spawning new processes by calling itself recursively."}]