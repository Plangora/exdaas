defmodule ExDaasWeb.ApiController do
  alias ExDaas.Cache.Counter.Model, as: Counter

  use ExDaasWeb, :controller

  @ets_tables Counter.shard_count_tables(:ets)

  def show(conn, %{"id" => id} = _params) do
    {_uid, table} = ets_table(id)
    [{_id, data}] = :ets.lookup(table, id)

    json(conn, %{id: id, data: data})
  end

  def create_or_update(conn, %{"id" => id, "data" => data} = _params) do
    {uid, table} = ets_table(id)

    json(conn, fetch(uid, data, table))
  end

  def cmd(conn, %{"id" => id, "cmd" => cmd} = _params) do
    %{"query" => query, "values" => values} = cmd

    {_uid, table} = ets_table(id)
    [{_id, data}] = :ets.lookup(table, id)

    case query do
      "ONLY" ->
        cmd(:only, conn, values, data)

      _lol_wut ->
        conn |> send_resp(500, "#{query} is not supported or invalid")
    end    
  end

  def cmd(:only, conn, values, data) do
    case values |> length do
      1 ->
        json(conn, Map.get(data, Enum.at(values, 0)))

      _ ->
        conn |> send_resp(500, "MORE THAN ONE ITEM IN A LIST IS NOT SUPPORTED LOL")
    end
  end

  defp fetch(id, data, ets_table) do
    ExDaas.Ets.Table.fetch(id, data, ets_table)
  end

  defp ets_table(id) do
    uid = Counter.new_id(id)
    shard = rem(uid, length(@ets_tables))

    {uid, Enum.at(@ets_tables, shard)}
  end
end
