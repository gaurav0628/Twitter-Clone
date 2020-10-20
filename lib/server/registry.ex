defmodule MyRegistry do
  @moduledoc false
  use GenServer
  require Logger

  @module_name MyRegistry

   def start_link(state) do
     Logger.info("MyRegistry started")
     GenServer.start_link(__MODULE__, state, name: @module_name)
   end


  def init(opts) do
    {:ok, opts}
  end

  def initialize_database() do
    Logger.info("Initializing database")
    :ets.new(:users, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:following, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:followers, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:all_tweets, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:all_hashtags, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:user_mentions, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
  end

  def sign_up(user_name, process_pid) do
    :ets.insert_new(:users, {user_name, process_pid})
  end

  def update_followers(user_pid, user_to_follow_pid) do
    following = cond do
      :ets.member(:following, user_pid) ->
        [{_user_pid, people_currently_following}] = :ets.lookup(:following, user_pid)
        people_currently_following ++ [user_to_follow_pid]
      true -> [user_to_follow_pid]
    end
    :ets.insert(:following, {user_pid, following})
    followers = cond do
      :ets.member(:followers, user_to_follow_pid) ->
        [{_user_pid, current_followers}] = :ets.lookup(:followers, user_to_follow_pid)
        current_followers ++ [user_pid]
      true -> [user_pid]
    end
    :ets.insert(:followers, {user_to_follow_pid, followers})
  end

  def insert_tweet(process_pid, text) do
    tweet = cond do
      :ets.member(:all_tweets, process_pid) ->
        [{_client_pid, list}] = :ets.lookup(:all_tweets, process_pid)
        [[text]] ++ list
      true ->
        [[text]]
    end
    :ets.insert(:all_tweets, {process_pid, tweet})

    get_from_tweet(text, 0, [], "#")
    |> Enum.each(
         fn (hash_tag) ->
           tweet = cond do
             :ets.member(:all_hashtags, hash_tag) ->
               [{_, list}] = :ets.lookup(:all_hashtags, hash_tag)
               [[tweet]] ++ list
             true -> [[text]]
           end
           Logger.info("Inserting #{tweet}")
           :ets.insert(:all_hashtags, {hash_tag, tweet})
         end
       )
    Logger.info("Tweet text: #{text}")
    get_from_tweet(text, 0, [], "@")
    |> Enum.each(
         fn (mentions) ->
           Logger.info("Mentioned: #{mentions}")
           mentions = get_process_pid(mentions)
           tweet = cond do
             :ets.member(:user_mentions, mentions) ->
               [{_, list}] = :ets.lookup(:user_mentions, mentions)
               [[tweet]] ++ list
             true -> [text]
           end
           :ets.insert(:user_mentions, {mentions, tweet})
         end
       )

  end

  def get_user_mentions(process_pid) do
    #TODO sorting tweets
    Logger.info("Getting mentions for reader")
    cond do
      :ets.member(:user_mentions, process_pid) ->
        [{_, tweets}] = :ets.lookup(:user_mentions, process_pid)
        Logger.info("Registry #{tweets}")
        tweets
      true -> []
    end
  end

  def get_followers(process_id) do
    try do
      [{_, followers}] = :ets.lookup(:followers, process_id)
      followers
    rescue
      _ -> []
    end
  end

  def get_following(process_id) do
    [{_user_pid, following}] = :ets.lookup(:following, process_id)
    following
  end

  def get_process_pid(user_name) do
    [{_name, pid}] = :ets.lookup(:users, user_name)
    pid
  end

  def get_tweets(process_pid) do
    #TODO sort tweets based on sequence number in descending order
    cond do
      :ets.member(:all_tweets, process_pid) ->
        [{_, tweets}] = :ets.lookup(:all_tweets, process_pid)
        tweets
      true -> []
    end
  end

  def get_tweet_with_hash_tag(hash_tag) do
    #IO.inspect hashtag
    #TODO do the sorting of tweets
    cond do
      :ets.member(:all_hashtags, hash_tag) ->
        [{_, tweets}] = :ets.lookup(:all_hashtags, hash_tag)
        tweets
      true -> []
    end
  end

  def get_from_tweet(text, index, list, what_to_get) do
    try do
      cond do
        String.length(text) == 0 -> list
        index == String.length(text) - 1 -> list
        String.at(text, index) == what_to_get -> get_from_tweet(text, index + 1, list, "", what_to_get)
        true -> get_from_tweet(text, index + 1, list, what_to_get)
      end
    rescue
      _ -> Logger.info("No need to return")
    end
  end

  def get_from_tweet(text, index, list, output, what_to_get) do
    cond do
      index == String.length(text) - 1 ->
        cond do
          String.at(text, index) == what_to_get -> list ++ [String.trim(output)]
          true ->
            acc = output <> String.at(text, index)
            list ++ [String.trim(acc)]
        end
      String.at(text, index) == "#" || String.at(text, index) == "@" ->
        cond do
          String.at(text, index) == what_to_get ->
            list = list ++ [String.trim(output)]
            get_from_tweet(text, index + 1, list, "", what_to_get)
          true ->
            list = list ++ [String.trim(output)]
            get_from_tweet(text, index + 1, list, what_to_get)
        end
      true ->
        out = output <> String.at(text, index)
        get_from_tweet(text, index + 1, list, out, what_to_get)
    end
  end

  def delete(user_name) do
    :ets.delete(:users, user_name)
  end


end
