defmodule Swell.DocumentStoreTest do
  use ExUnit.Case
  alias Swell.DocumentStore

  setup_all do
    start_supervised! {DocumentStore, %{}}
    :ok
  end

  test "puts and gets valus correctly" do
    assert DocumentStore.get("order", "123") == nil
    DocumentStore.put("order", "123", "order123")
    DocumentStore.put("order", "456", "order456")
    assert DocumentStore.get("order", "123") == "order123"
    assert DocumentStore.get("order", "456") == "order456"
    DocumentStore.delete("order", "456")
    assert DocumentStore.get("order", "123") == "order123"
    assert DocumentStore.get("order", "456") == nil
    DocumentStore.delete("order", "123")
    assert DocumentStore.get("order", "123") == nil
    assert DocumentStore.get("order", "456") == nil
  end

end
