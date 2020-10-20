defmodule Simulate do
  @moduledoc false
  use GenServer
  require Logger

  def start_simulation(number_of_clients) do
    :ets.new(:users, [:set, :public, :named_table])
    Node.start (String.to_atom("simulation20@127.0.0.1"))
    all_process_ids = create_clients(number_of_clients, [])
  end

  def subscribe(all_process_ids) do
    number_of_users = length(all_process_ids)
    number_of_subscribers = number_of_users - 1
    subscribe(all_process_ids, number_of_users - 1, number_of_subscribers, 1)
  end

  def subscribe(_all_process_ids, -1, _number_of_subscribers, _factor) do
    true
  end

  def subscribe(all_process_ids, index, number_of_subscribers, factor) do
    process_id = Enum.at(all_process_ids, index)
    number_of_subscribers_to_set = (number_of_subscribers / factor)
                                   |> round
    number_of_subscribers_to_set = cond do
      number_of_subscribers_to_set == 0 ->
        1
      true ->
        number_of_subscribers_to_set
    end
    user_to_subscribe_process_id = Enum.take_random(all_process_ids -- [process_id], number_of_subscribers_to_set)
    user_name_to_subscribe = Enum.map(
      user_to_subscribe_process_id,
      fn (user_process_id) ->
        get_user_name(user_process_id)
      end
    )

    [{_, userName, followers}] = :ets.lookup(:users, process_id)
    followers = followers ++ user_to_subscribe_process_id
    :ets.insert(:users, {process_id, userName, followers})

    GenServer.cast(process_id, {:subscribe_users, user_name_to_subscribe})
    subscribe(all_process_ids, index - 1, number_of_subscribers, factor + 1)
  end

  def send_tweets(all_process_ids, interval_time, action, number_of_messages) do
    number_of_users = length(all_process_ids)
    Enum.each(
      all_process_ids,
      fn (client) ->
        mention = get_random_mention(all_process_ids, client)
                  |> get_user_name
        tweet = "tweet@" <> mention <> random_hash_tags()

        [{_process_id, _user_name, subscribers}] = :ets.lookup(:users, client)
        subscribers = length(subscribers)
        interval = (
          number_of_users / subscribers
          |> round) * interval_time
        user_name = get_user_name(client)
        send client, {action, tweet, user_name, client, interval, number_of_messages*1000}
      end
    )
  end

  def get_tweets(all_user_pids) do
    Enum.each(
      all_user_pids,
      fn (client) ->
        userName = get_user_name(client)
        GenServer.cast(client, {:get_all_tweets, userName})
      end
    )
  end

  def get_tweets(pids, :interval) do
    Enum.each(
      pids,
      fn (client) ->
        name = get_user_name(client)
        send client, {:get_all_tweets, name, client}
      end
    )
  end

  def get_hash_tags(client_pids) do
    Enum.each(
      client_pids,
      fn (pid) ->
        name = get_user_name(pid)
        hash_tags = [random_hash_tags()]
        #TODO need to change
        GenServer.cast(pid, {:get_hash_tags, name, hash_tags})
      end
    )
  end

  def get_random_mention(pids, user_process_id) do
    mention = Enum.random(pids)
    cond do
      mention == user_process_id ->
        get_random_mention(pids, user_process_id)
      true ->
        mention
    end
  end

  def get_mentions(pids) do
    Enum.each(
      pids,
      fn (client) ->
        name = get_user_name(client)
        #TODO need to change
        GenServer.cast(client, {:get_mentions, name})
      end
    )
  end

  def get_user_name(pid) do
    [{_process_id, user_name, _followers}] = :ets.lookup(:users, pid)
    user_name
  end

  def random_hash_tags do
    hash_tags = [
      "#Florida",
      "#floridalife",
      "#floridakeys",
      "#floridaliving",
      "#floridarealestate",
      "#floridagirl",
      "#floridaphotographer",
      "#FloridaWedding",
      "#floridafishing",
      "#floridaBoy",
      "#floridarealtor",
      "#floridabarber",
      "#FloridaState",
      "#floridablanca",
      "#floridagators",
      "#floridahairstylist",
      "#FloridaGeorgiaLine",
      "#Floridahair",
      "#floridamodel",
      "#floridaartist",
      "#floridahomes",
      "#floridabeaches",
      "#floridastylist",
      "#floridasunset",
      "#floridablogger",
      "#floridaweddingphotographer",
      "#floridaedm",
      "#floridastyle",
      "#floridawildlife",
      "#floridaweddings"
    ]
    Enum.random(hash_tags)
  end

  def create_clients(0, all_process_ids) do
    all_process_ids
  end

  def create_clients(number_of_clients_to_create, all_process_ids) do
    Logger.info("Starting clients")
    state = 0
    name = number_of_clients_to_create
           |> Integer.to_string
           |> String.to_atom
    {:ok, process_id} = GenServer.start(User, state, name: name)
    all_process_ids = all_process_ids ++ [process_id]
    user_name = :md5
                |> :crypto.hash(Kernel.inspect(process_id))
                |> Base.encode16()
    :ets.insert_new(:users, {process_id, user_name, []})

    GenServer.call(process_id, {:sign_up, user_name}, :infinity)
    create_clients(number_of_clients_to_create - 1, all_process_ids)
  end

end