defmodule TwitterProject do
  use GenServer
  require Logger

  def main(args) do
    IO.puts("Starting project")
    input = Enum.at(args, 0)
    IO.puts("Got input #{input}")

    cond do
      input == "server" ->
        Logger.info("Starting server")
        number_of_reads = 0
        hits = 0
        number_of_writes = 0
        actor_count = 0
        state = {number_of_reads, number_of_writes, actor_count, hits}
        {:ok, _process_id} = GenServer.start(Server, state, name: :server)
        GenServer.call(:server, :start, :infinity)
        Logger.info("The server returns")
      input == "simulator" ->
        num_User = String.to_integer(Enum.at(args, 1))
        num_Messages = String.to_integer(Enum.at(args, 2))
        all_process_ids = Simulate.start_simulation(num_User)
        Simulate.subscribe(all_process_ids)
        Simulate.send_tweets(all_process_ids, 1, :start_simulation, num_Messages)
      true ->
        true
    end
    receive do
      :test ->
        IO.puts "test"
    end
  end
end
