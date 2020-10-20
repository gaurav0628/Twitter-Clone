defmodule Writer do
  @moduledoc false
  use GenServer

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_cast({:write_tweet, process_pid, text}, state) do
    MyRegistry.insert_tweet(process_pid, text)
    {:noreply, state}
  end
end