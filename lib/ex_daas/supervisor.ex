defmodule ExDaas.Supervisor do
  alias ExDaas.Ets.Table, as: EtsTable
  alias ExDaas.Dets.Table, as: DetsTable

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    ets_table_names = 0..3 |> Enum.map(fn i -> :"ets_table_#{i}" end)
    dets_table_names = 0..3 |> Enum.map(fn i -> :"dets_table_#{i}" end)

    dets_tables = dets_table_names
    |> Enum.with_index
    |> Enum.map(fn {t, i} ->
      worker(DetsTable, [[name: t, ets_tables: ets_table_names]], [id: i])
    end)

    ets_tables = ets_table_names
    |> Enum.with_index
    |> Enum.map(fn {name, i} ->
      worker(EtsTable, 
        [[name: name, ets_tables: ets_table_names, dets_tables: dets_table_names]],
        [id: i + 4]
      )
    end)

    counter_table = [
      worker(DetsTable, [[name: :dets_counter, ets_tables: ets_table_names]], [id: 8]),
    ]
    
    children = ets_tables ++ counter_table ++ dets_tables
    
    supervise(children, strategy: :one_for_one)
  end
end
