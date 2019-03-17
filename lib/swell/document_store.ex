defmodule Swell.DocumentStore do
  use Agent
  @me __MODULE__

  def start_link(bucket \\ %{}) do
    Agent.start_link(fn -> bucket end, name: @me)
  end

  def get(type, id) do
    Agent.get(@me, & &1[type][id])
  end

  def put(type, id, value) do
    Agent.update(@me, &put_in_bucket(&1, type, id, value))
  end

  defp put_in_bucket(bucket, type, id, value) do
    Map.update(
      bucket,
      type,
      %{id => value},
      &Map.put(&1, id, value)
    )
  end

  def delete(type, id) do
    Agent.update(@me, &delete_from_bucket(&1, type, id))
  end

  defp delete_from_bucket(bucket, type, id) do
    if Map.has_key?(bucket, type) do
      Map.put(
        bucket,
        type,
        Map.drop(bucket[type], [id])
      )
    end
  end

end
