defmodule User do
  use GenServer

  require Logger

  @server_name :"TwitterEngine20@127.0.0.1"

  def handle_cast({:subscribe_users, users}, state) do
    GenServer.call({:server, @server_name}, {:subscribe_users, users}, :infinity)
    {:noreply, state}
  end

  def handle_call({:sign_up, user}, _, state) do
    GenServer.call({:server, @server_name}, {:sign_up, user}, :infinity)
    {:reply, (:registered), state}
  end

  def handle_info({:subscribers_list, process_id, tweet, user, interval}, state) do
    GenServer.cast({:server, @server_name}, {:subscribe_users, tweet, user})
    state = state + 1
    cond do
      state <= 1000 ->
        Process.send_after(process_id, {:subscribers_list, tweet, user, interval}, interval)
      true ->
        true
    end
    {:noreply, state}
  end

  def handle_cast({:get_hash_tags, user, hash_tags}, state) do
    GenServer.cast({:server, @server_name}, {:get_hash_tags, user, hash_tags})
    {:noreply, state}
  end

  def handle_cast({:get_all_tweets, user}, state) do
    time = :os.system_time(:milli_seconds)
    GenServer.cast({:server, @server_name}, {:search, user, time})
    {:noreply, state}
  end

  def handle_cast({:get_mentions, user}, state) do
    GenServer.cast({:server, @server_name}, {:get_mentions, user})
    {:noreply, state}
  end

  def handle_info({:start_simulation, tweet, name, process_id, time_interval, number_of_messages}, count) do
    count = count + 1
    cond do
      rem(count, 1000) == 0 ->
        choice = Enum.random([:get_hash_tags, :get_mentions, :get_all_tweets, :retweet])
        case choice do
          :get_hash_tags ->
            Logger.info("User #{name} requesting for hash tags")
            hash_tags = [Simulate.random_hash_tags]
            GenServer.cast({:server, @server_name}, {:get_hash_tags, name, hash_tags})
          :get_mentions ->
            Logger.info("User #{name} requesting for mentions")
            GenServer.cast({:server, @server_name}, {:get_mentions, name})
          :get_all_tweets ->
            Logger.info("User #{name} requesting for tweets")
            time = :os.system_time(:milli_seconds)
            GenServer.cast({:server, @server_name}, {:get_all_tweets, name, time})
          :retweet ->
            Logger.info("User #{name} re-tweeting")
            hash_tags = [Simulate.random_hash_tags()]
            GenServer.cast({:server, @server_name}, {:retweet, name, hash_tags})
          _ ->
            true
        end
        Process.send_after(
          process_id,
          {:start_simulation, tweet, name, process_id, time_interval, number_of_messages},
          time_interval
        )
      count >= number_of_messages ->
        Logger.info("#{name} exiting")
        IO.puts "deleting user #{name}"
        GenServer.call({:server, @server_name}, {:delete_user, name})
        {:noreply, count}
      true ->
        GenServer.cast({:server, @server_name}, {:update_subscribers, :os.system_time(:milli_seconds), tweet, name})
        Process.send_after(
          process_id,
          {:start_simulation, tweet, name, process_id, time_interval, number_of_messages},
          time_interval
        )
    end
    {:noreply, count}
  end

  def handle_cast({:process_tweet, _time, _tweet}, state) do
    #Logger.info("Received Tweet because person I'm following tweeted something")
    {:noreply, state}
  end

  def handle_cast({:process_tweet, _tweet}, state) do
    #Logger.info("Received Tweet because was mentioned")
    {:noreply, state}
  end

  def handle_cast({:search_result, _tweets}, state) do
    Logger.info("Received Tweets")
    {:noreply, state}
  end

  def handle_cast({:result_of_hash_tags, tweet}, state) do
    Logger.info("Received Tweets with HashTags")
    {:noreply, state}
  end

  def handle_cast({:result_of_mentions, tweet}, state) do
    Logger.info("Received Tweets with Mentions")
    {:noreply, state}
  end

  def handle_cast({:retweet, user, tweets}, state) do
    cond do
      length(tweets) > 0 ->
        tweet = Enum.random(tweets)
                |> Enum.at(1)
        GenServer.cast({:server, @server_name}, {:update_subscribers, :os.system_time(:milli_seconds), tweet, user})
      true ->
        true
    end
    {:noreply, state}
  end

  def init(state) do
    {:ok, state}
  end
end