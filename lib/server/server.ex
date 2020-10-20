defmodule Server do
  @moduledoc false
  use GenServer
  require Logger

  def init(opts) do
    start_readers()
    start_tweeters()
    start_writers()
    start_utility()
    {:ok, opts}
  end

  def start_readers() do
    Logger.info("Starting readers")
    Enum.each(
      0..1000,
      fn (index) ->
        actor = "reader" <> Integer.to_string(index)
                |> String.to_atom()
        GenServer.start(Reader, :running, name: actor)
      end
    )
  end

  def start_tweeters() do
    Logger.info("Starting Tweeters")
    Enum.each(
      0..1000,
      fn (index) ->
        actor = "tweeter" <> Integer.to_string(index)
                |> String.to_atom()
        GenServer.start(Tweeter, :running, name: actor)
      end
    )
  end

  def start_writers() do
    Logger.info("Starting writers")
    GenServer.start(Writer, :running, name: :writer1)
    GenServer.start(Writer, :running, name: :writer2)
  end

  def start_utility() do
    MyRegistry.initialize_database()
    ServerUtility.start_utility()
  end

  def handle_call({:sign_up, user_name}, process_id, state) do
    MyRegistry.sign_up(
      user_name,
      process_id |> elem(0)
    )
    {:reply, :done, state}
  end

  def handle_call({:subscribe_users, users_to_subscribe}, client, state) do
    process_id = client
                 |> elem(0)
    users_to_subscribe
    |> Enum.each(
         fn (user_name) ->
           user_process_id = MyRegistry.get_process_pid(user_name)
           MyRegistry.update_followers(process_id, user_name)
         end
       )
    {:reply, {:done}, state}
  end

  def handle_cast({:update_subscribers, time, tweet, user_name}, state) do
    Logger.info("Username: #{user_name}, tweet: #{tweet}, time #{time}")
    user_process_id = MyRegistry.get_process_pid(user_name)
    state = {100, 100, 100, 100}
    state = ServerUtility.send_tweets_to_followers(tweet, user_process_id, time, state)
    state = ServerUtility.write(user_process_id, tweet, state)
    {:noreply, state}
  end


  def handle_cast({:retweet, user_name, hash_tags}, state) do
    user_process_id = MyRegistry.get_process_pid(user_name)
    state = ServerUtility.re_tweet(state, user_process_id, user_name, hash_tags)
    {:noreply, state}
  end

  def handle_cast({:get_all_tweets, user_name, time}, state) do
    user_process_id = MyRegistry.get_process_pid(user_name)
    state = ServerUtility.read(state, user_process_id, time)
    {:noreply, state}
  end

  def handle_cast({:get_hash_tags, user_name, hash_tags}, state) do
    user_process_id = MyRegistry.get_process_pid(user_name)
    state = ServerUtility.get_hash_tags(state, user_process_id, hash_tags)
    {:noreply, state}
  end

  def handle_cast({:get_mentions, user_name}, state) do
    user_process_id = MyRegistry.get_process_pid(user_name)
    state = ServerUtility.get_mentions(state, user_process_id)
    {:noreply, state}
  end

  def handle_call({:delete_user, user_name}, _from, state) do
    MyRegistry.delete(user_name)
    {:reply, :done, state}
  end

  def start_link(opts \\ []) do
    {:ok, _pid} = GenServer.start_link(Server, [], opts)
  end

end
