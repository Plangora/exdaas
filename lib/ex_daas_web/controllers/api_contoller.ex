defmodule ExDaasWeb.ApiController do
  use ExDaasWeb, :controller

  @data %{color: "blue"}
  @en 0..3 |> Enum.map(fn i -> :"ets_table_#{i}" end)

  def find_or_create(conn, %{"id" => id, "data" => data} = _params) do
    shard = rem(id, length(@ets_table_names))

    json conn, fetch(id, data, Enum.at(@ets_table_names, shard))
  end

  defp fetch(id, data, ets_table) do
    ExDaas.Ets.Table.fetch(id, data, ets_table)
  end

  def test(num) do
    0..num |> Enum.map(fn i ->
      Task.async(fn ->
        ExDaas.Ets.Table.fetch(i, @data, Enum.at(@en, rem(i, length(@en))))
      end)
    end)
    |> Enum.each(fn t -> Task.await(t) end)
  end
end
