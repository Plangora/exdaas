defmodule ExDaas.Ets.Table do
  alias ExDaas.Cache.Model, as: Model

  use GenServer

  def start_link(opts \\ []) do
    [name: name, ets_tables: ets_tables, dets_tables: dets_tables] = opts

    GenServer.start_link(__MODULE__, [
      {:name, name},
      {:log_limit, 1_000_000},
      {:ets_tables, ets_tables},
      {:dets_tables, dets_tables},
    ], opts)
  end

  def fetch(id, data, ets_table) do
    GenServer.call(ets_table, {:fetch, {id, data, ets_table}})
  end

  def handle_call({:fetch, {id, data, ets_table}}, _from, state) do
    %{dets_tables: dets_tables} = state

    case is_number(id) do
      true ->
        table = Enum.at(dets_tables, rem(id, length(dets_tables)))
        {:reply, Model.fetch(id, data, :ets_table_0, table), state}
      false ->
        {:reply, Model.new_user(data, :ets_table_0, dets_tables), state}
    end
  end

  def init(args) do
    [
      {:name, name},
      {:log_limit, log_limit},
      {:ets_tables, ets_tables},
      {:dets_tables, dets_tables},
    ] = args
    

    IO.puts name
    :ets.new(name, [:named_table, :set, :public])
    
    {:ok,
      %{
        log_limit: log_limit,
        name: name,
        ets_tables: ets_tables,
        dets_tables: dets_tables,
        read_concurrency: true,
      },
    }
  end
end
