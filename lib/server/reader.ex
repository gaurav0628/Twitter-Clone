defmodule Reader do
  @moduledoc false
  use GenServer
  require Logger

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:retweet, user_process_id, user_name, hash_tags}, state) do
    Enum.each(
      hash_tags,
      fn (hash_tag) ->
        tweets = String.replace(hash_tag, "#", "")
                 |> MyRegistry.get_tweet_with_hash_tag()
        #TODO Change this
        # GenServer.cast(user_process_id, {:retweet, user_name, tweets})
        send user_process_id, {:search_result, tweets |> Enum.at(1)}
      end
    )
    {:noreply, state}
  end

  def handle_cast({:search, user_process_id, hit, request_time}, state) do
    MyRegistry.get_following(user_process_id)
    |> Enum.each(
         fn (following) ->
           tweets = MyRegistry.get_tweets(following)
           #GenServer.cast(user_process_id, {:search_result, tweets})
           Logger.info("Reader #{tweets}")
           send user_process_id, {:search_result, tweets}
         end
       )
    IO.inspect ["search processing time for tweet num #{hit}", :os.system_time(:milli_seconds) - request_time]

    {:noreply, state}
  end

  def handle_cast({:get_hash_tags, user_process_id, hash_tags}, state) do
    IO.inspect hash_tags
    Enum.each(
      hash_tags,
      fn (hash_tag) ->
        String.replace(hash_tag, "#", "")
        |> MyRegistry.get_tweet_with_hash_tag
        |> Enum.each(
             fn (tweet) ->
               # GenServer.cast(user_process_id, {:result_of_hash_tags, tweet})
               Logger.info("#{tweet}")
               send user_process_id, {:result_of_hash_tags, tweet}
             end
           )
      end
    )
    {:noreply, state}
  end

  def handle_cast({:get_mentions, user_process_id}, state) do
    text = MyRegistry.get_user_mentions(user_process_id)
    send user_process_id, {:result_of_mentions, text}
    {:noreply, state}
  end

end
