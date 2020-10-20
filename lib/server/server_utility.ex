defmodule ServerUtility do
  @moduledoc false
  use GenServer
  require Logger

  def send_tweets_to_mentions(tweet) do
    tweet
    |> MyRegistry.get_from_tweet(0, [], "@")
    |> Enum.each(
         fn (mentions) ->
           process_id = MyRegistry.get_process_pid(mentions)
           #TODO: check if exception is thrown
           GenServer.cast(process_id, {:process_tweet, tweet})
         end
       )
  end

  def send_tweets_to_followers(tweet, user_process_id, time, state) do
    {number_of_reads, number_of_writes, actor_count, hits} = state
    hits = hits + 1
    cond do
      rem(hits, 1000) == 0 ->
        IO.inspect ["Server: Processing time", hits + 1, :os.system_time(:milli_seconds) / 1000]
      true -> true
    end
    actor_count = rem(actor_count + 1, 1000)
    actor = "tweeter" <> Integer.to_string(actor_count)
            |> String.to_atom()
    GenServer.cast(actor, {:send_tweets_to_subscribers, user_process_id, time, tweet})
    state = {number_of_reads, number_of_writes, actor_count, hits}
  end

  def write(client_pid, tweet, state) do
    {number_of_reads, number_of_writes, actor_count, hits} = state
    number_of_writes =
      cond do
        number_of_writes == 0 ->
          GenServer.cast(:writer1, {:write_tweet, client_pid, tweet})
          1
        true ->
          GenServer.cast(:writer2, {:write_tweet, client_pid, tweet})
          0
      end
    {number_of_reads, number_of_writes, actor_count, hits}
  end

  def read(state, client_id, time) do
    {number_of_reads, number_of_writes, actor_count, hits} = state
    number_of_reads = rem((number_of_reads + 1), 1000)
    actor = "reader" <> Integer.to_string(number_of_reads)
            |> String.to_atom()

    GenServer.cast(actor, {:search, client_id, time, hits + 1})

    {number_of_reads, number_of_writes, actor_count, hits + 1}
  end

  def get_hash_tags(state, client_id, hash_tags) do
    Logger.info("#{hash_tags}")
    {number_of_reads, number_of_writes, actor_count, hits} = state
    number_of_reads = rem((number_of_reads + 1), 1000)
    actor = "reader" <> Integer.to_string(number_of_reads)
            |> String.to_atom()

    GenServer.cast(actor, {:get_hash_tags, client_id, hash_tags})

    {number_of_reads, number_of_writes, actor_count, hits + 1}
  end

  def get_mentions(state, client_id) do
    {number_of_reads, number_of_writes, actor_count, hits} = state
    number_of_reads = rem((number_of_reads + 1), 1000)
    actor = "reader" <> Integer.to_string(number_of_reads)
            |> String.to_atom()
    GenServer.cast(actor, {:get_mentions, client_id})
    {number_of_reads, number_of_writes, actor_count, hits + 1}
  end

  def re_tweet(state, client_id, user_name, hash_tags) do
    {number_of_reads, number_of_writes, actor_count, hits} = state
    number_of_reads = rem((number_of_reads + 1), 1000)
    actor = "reader" <> Integer.to_string(number_of_reads)
            |> String.to_atom()

    GenServer.cast(actor, {:retweet, client_id, user_name, hash_tags})

    {number_of_reads, number_of_writes, actor_count, hits + 1}
  end

  def start_utility() do
    Node.start (String.to_atom("TwitterEngine20@127.0.0.1"))
    IO.inspect {Node.self}
  end

end
