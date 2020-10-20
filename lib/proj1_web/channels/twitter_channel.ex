defmodule Proj1Web.TwitterChannel do
    use Phoenix.Channel
    require Logger

    #helps in signing up the user
    def handle_in("sign_up", user_name, socket) do
        GenServer.call(:server, {:sign_up, user_name})
        push socket, "signed up",  %{"user_name" => user_name}
        {:reply, :done, socket}
    end

    def join("room:lobby", _message, socket) do
        {:ok, socket}
    end

    def join("twitter:"<> _id, _param, _socket) do
        {:error, %{reason: "Not Authorized"}}
    end

    def handle_in("subscribe", params, socket) do
       user_name = params["user_name"]
       user_to_subscribe = params["user_to_subscribe"] # A list of user_names
       GenServer.call(:server, {:subscribe_users, user_to_subscribe})
       push socket, "Subscribed to user",  %{"user_name" => user_name}
       {:reply, :done, socket}
    end

    def handle_in("tweet_subscribers", payload, socket) do
     tweet = payload["tweet"]
     name = payload["user_name"]
     tweet_time =  payload["time"]
     GenServer.cast(:server, {:update_subscribers, tweet_time, tweet, name})
     {:noreply, socket}
   end

   def handle_in("get_all_tweets", params, socket) do
       user_name = params["user_name"]
       time = params["time"]
       GenServer.cast(:server, {:get_all_tweets, user_name, time})
       {:noreply, socket}
   end

   def handle_in("get_hash_tags", params, socket) do
    user_name = params["user_name"]
    hash_tags = params["hash_tags"]
    time = params["time"]
    GenServer.cast(:server, {:get_hash_tags, user_name, hash_tags})
    {:noreply, socket}
  end

  def handle_in("get_mentions", params, socket) do
     user_name = params["user_name"]
     time = params["time"]
     GenServer.cast(:server, {:get_mentions, user_name})
     {:noreply, socket}
   end

   def handle_in("retweet", params, socket) do
     user_name = params["user_name"]
     tweet = params["tweet"]
     hash_tags = [Simulate.random_hash_tags()]
     GenServer.cast(:server, {:retweet, user_name, hash_tags})
     {:noreply, socket}
   end

   def handle_info({:search_result, tweet}, socket) do
     push socket, "search_result", %{"tweet" => tweet}
     {:noreply, socket}
   end

   def handle_info({:result_of_hash_tags, tweet}, socket) do
     Logger.info("Result #{tweet}")
     push socket, "result_of_hash_tags", %{"tweet" => tweet}
     {:noreply, socket}
   end

   def handle_info({:result_of_mentions, tweet}, socket) do
     push socket, "result_of_mentions", %{"tweet" => tweet}
     {:noreply, socket}
   end

   def handle_info({:retweet_result, user_name, tweet}, socket) do
     push socket, "search_retweet", %{"tweet" => tweet}
     {:noreply, socket}
   end

   def handle_info(tweet, socket) do
     push socket, "tweet", tweet
     {:noreply, socket}
   end

end
