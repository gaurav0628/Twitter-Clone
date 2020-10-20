// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channelsList, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

//let socket = new Socket("/socket", {params: {token: window.userToken}})

var numClients
var channelsList = []
var socketsList = []
let maxClients = 1
let userFollowers = {}
let userNamesList = []
//let userName
let messageContainer = document.querySelector('#messages')
var clientsProcessed = 0
let channel

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()
channel = socket.channel("room:lobby", {})

//join the new client
channel.join()
.receive("ok", resp => { console.log("Joined successfully", resp) })
.receive("error", resp => { console.log("Unable to join", resp) })

function register(userName){
    //register the new client
    channel.push("sign_up", userName)
    .receive("done" , resp => console.log("registered", resp))
}

//give subscribers to each client
function subscribe(user, subscribersList) {
    channel.push("subscribe", {user_name: user, user_to_subscribe: subscribersList})
    .receive("subscribed", resp => console.log("subscribed", user))
    console.log({username: user, usersToSub: subscribersList})
}

/**function to send tweets */

 function sendTweet(tweetText, username){
   channel.push("tweet_subscribers", {tweet: tweetText,
    user_name: username, time: `${Date()}`})
    console.log( {tweetText: tweetText,
        username: username, time: `${Date()}`})
 }



/////////////////////////////////////////////////////////////////////////////
//KEY PRESS EVENT LISTENERS BELOW THIS

//let channel = socket.channel("room:lobby", {})
let username = document.querySelector('#username')
let subscription = document.querySelector('#subscribe')
let search_user_tweets = document.querySelector('#search_user_tweets')
//et messageContainer = document.querySelector('#messages')


/**event listener to  register username*/
username.addEventListener("keypress", event => {
  if (event.keyCode === 13){
      register(username.value)
      let messageItem = document.createElement("li");
      messageItem.innerText = `${username.value} logged in at [${Date()}]`
      messageContainer.appendChild(messageItem)
      //username.value = ""
  }
})

/**event listener to  register username*/
subscription.addEventListener("keypress", event => {
    if (event.keyCode === 13){
        var val = document.getElementById('subscribe').value
        subscribe(val, [username.value])
        let messageItem = document.createElement("li");
        messageItem.innerText = `${username.value} subscribed to ${val} at [${Date()}]`
        messageContainer.appendChild(messageItem)
        subscribe.value = ""
    }
  })

/**event listener to  send tweets*/
sendtweet.addEventListener("keypress", event => {
    if (event.keyCode === 13){
        sendTweet(sendtweet.value, username.value)
        let messageItem = document.createElement("li");
        messageItem.innerText = `${username.value} tweeted: ${sendtweet.value} at [${Date()}]`
        messageContainer.appendChild(messageItem)
        sendtweet.value = ""
    }
  })


/**event listener to  search tweets of all
 * users you have subscribed to*/
 document.getElementById('search_user_tweets').onclick = function () {
     //var val = document.getElementById('search_user_tweets').value
     console.log({user_name: username.value, time: `${Date()}`})
     channel.push("get_all_tweets", {user_name: username.value, time: `${Date()}`})
    }

/**event listener to  search for a hashtag*/
search_hashtag.addEventListener("keypress", event => {
    if (event.keyCode === 13){
        channel.push("get_hash_tags", {user_name: username.value, hash_tags: [search_hashtag.value], time: `${Date()}`})
        console.log({user_name: username.value, hash_tags: [search_hashtag.value], time: `${Date()}`})
        search_hashtag.value = ""
    }
  })

  /**event listener to  search for tweets where you are mentioned*/
  document.getElementById('search_mentions').onclick = function () {
    //var val = document.getElementById('search_user_tweets').value
    channel.push("get_mentions", {user_name: username.value, time: `${Date()}`})
   }

  /**event listener to  search for tweets where you are mentioned*/
  document.getElementById('clear_screen').onclick = function () {
    messageContainer.innerHTML=""
   }

/////////////////////////////////////////////////////////////////////////////
//EVENT LISTENERS BELOW THIS

/**event listener to receive tweet from
 * the user this user has subscribed to*/
channel.on("tweet_sub", payload => {
    let messageDiv = document.createElement("div")
    let messageItem = document.createElement("li");
    let messageButton = document.createElement("button");

    messageDiv.appendChild(messageItem)
    messageDiv.appendChild(messageButton)
    messageItem.innerText = `Tweeted: [${Date()}] ${payload.tweetText}`
    messageButton.innerText = "RETWEET"
    messageButton.style.display = "inline"
    messageButton.addEventListener('click', ()=>{
        channel.push("retweet", {username: username.value, tweetText: payload.tweetText})
    })
    // messageButton.style.float ="right"
    console.log(messageItem.innerText)
    messageContainer.appendChild(messageDiv)
  })

/**even listener to receive search results as tweets from a
 * paticular user who's tweet are searched for */
channel.on("search_result", payload => {
    let messageItem = document.createElement("li");
    messageItem.innerText = `Search Result: [${Date()}] ${payload.tweet}`
    messageContainer.appendChild(messageItem)
  })

/**event listener to receive tweets for a particular
 * hashtag searched for by this user */
channel.on("result_of_hash_tags", payload => {
    let messageItem = document.createElement("li");
    messageItem.innerText = `Search Hash Tag: [${Date()}] ${payload.tweet}`
    messageContainer.appendChild(messageItem)
  })

/**event listener to receive tweets for
 * mentions searched by this user */
channel.on("result_of_mentions", payload => {
    console.log(payload.tweet)
    let messageItem = document.createElement("li");
    messageItem.innerText = `Search Mentions: [${Date()}] ${payload.tweet}`
    messageContainer.appendChild(messageItem)
  })


//////////////////////////////////////////////////////////////////////////////////////////////////////
/**ALL HELPER FUNCTIONS BELOW THIS */

/** function to get random subscribers*/
function getRandom(arr, n, i) {
  var result = new Array(n),
  len = arr.length,
  taken = new Array(len);
  if (n > len)
    throw new RangeError("getRandom: more elements taken than available");
  while (n--) {
    var x = randNum(arr, i);
    result[n] = arr[x in taken ? taken[x] : x];
    taken[x] = --len;
  }
  return result;
}

function randNum(arr,excludeNum){
  var randNumber = Math.floor(Math.random()*arr.length);
  if(arr[randNumber]==excludeNum){
      return randNum(arr,excludeNum);
  }else{
      return randNumber;
  }
}

/**function to get random hashtag */
function getHashtag(){
  var hashList = ["#Florida",
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
  "#floridaweddings"]
  return hashList[Math.floor(Math.random() * hashList.length)]
}


export default socketsList
