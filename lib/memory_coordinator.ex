defmodule MemoryCoordinator do
  @moduledoc """
  Stores state within a process of coordinate results used in the
  PizzaFactoryLocator.determine_new_factory_location funtion. Using the GenServer Module,
  This module aids in the parallel processing of pizza orders and factories
  """
  use GenServer

  # Client Side
  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def get_result(pid) do
    GenServer.call(pid, :get_result)
  end

  def update_result(pid, result) when is_list(result) do
    length(result) == 3 || raise "the parameter should be a list with 3 float elements"

    Enum.each(0..(length(result) - 1), fn x ->
      is_float(Enum.at(result, x)) ||
        raise "invalid element provided in list. Elements should be floats"
    end)

    GenServer.call(pid, {:update_result, result})
  end

  def get_closest_factory(pid) do
    GenServer.call(pid, :get_closest_factory)
  end

  def update_closest_factory(pid, closest_factory) do
    GenServer.call(pid, {:update_closest_factory, closest_factory})
  end

  # Server Side
  def init(state) do
    {:ok, state}
  end

  def handle_call(:get_result, _form, state) do
    state = (state == [] && [0.0, 0.0, 0.0]) || state

    {:reply, state, state}
  end

  def handle_call({:update_result, result}, _form, _state) do
    state = result

    {:reply, :ok, state}
  end

  def handle_call(:get_closest_factory, _form, state) do
    {:reply, state, state}
  end

  def handle_call({:update_closest_factory, closest_factory}, _form, _state) do
    state = closest_factory

    {:reply, :ok, state}
  end
end
