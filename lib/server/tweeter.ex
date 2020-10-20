defmodule Tweeter do
  @moduledoc false
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:send_tweets_to_subscribers, user_process_id, tweet_time, tweet}, state) do
    user_process_id
    |> MyRegistry.get_followers()
    |> Enum.each(
         fn (pid) ->
           GenServer.cast(pid, {:process_tweet, tweet_time, tweet})
         end
       )

    {:noreply, state}
  end

end
