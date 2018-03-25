defmodule ExDaasWeb.ApiController do
  use ExDaasWeb, :controller

  def find_or_create(conn, %{"id" => id, "data" => data} = _params) do
    json conn, fetch(id, data, :"ets_table_0")
  end

  defp fetch(id, data, ets_table) do
    ExDaas.Ets.Table.fetch(id, data, ets_table)
  end
end
