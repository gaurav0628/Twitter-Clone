# Twitter-Simulator

The application is a twitter simulator based on Elixir. It is a distributed system which mimics Twitter environment. The application can be used by client/users to login and perform the functionality of tweeting, subscribing etcetera, just like on Twitter. The backend of the application is in Service Oriented Architecture and is based on Elixir and Phoenix framework. The front end comprises of Javascript and CSS. The application can be launched in a client mode which allows one to signup and use the functionalities or in simulation mode which is a no touch , where you can just run the application and the system will automatically create users that interact dynamically with each other.

There are 2 major components of this project, server and client. Client behaves as individual twitter userwho can use twitter functionalities and server behaves as the Twitter Engine which is responsible for providing the features to multiple clients simultaneously. Following are the features which are provided by the twitter engine to the users in our simulation :

**Steps to Run : **

*Server :*

● Navigate to project directory
● Run “epmd -daemon”
● Run “mix escript.build”
● Run “./twitter server ”

*Client :*

● Navigate to project directory
● Run “./twitter simulator numUsers numMessages”

*Functionalities Implemented :*

● Send tweet. Tweets can have hashtags (e.g. #COP5615isgreat) and mentions
(@bestuser)
● Subscribe to user's tweets.
● Querying tweets subscribed to, tweets with specific hashtags,
● Tweets in which the user is mentioned (my mentions).

**STEPS TO RUN :**

*CLIENT :*

● Go to assets > js folder from the directory of project
● Open app.js file and do the following edits
● Comment the line import socket from "./socket" , and uncomment the line import
socket from "./solo_socket". Continue if already so.
● In the main project directory run, from terminal, the command mix phx.server .
● Open a browser and run localhost:4000 to access a client. You can also open
multiple tabs for multiple clients.
● Different functionalities can then be simulated on this client.

*SIMULATOR :*

● Go to assets > js folder from the directory of project
● Open app.js file and do the following edits
● Uncomment the line import socket from "./socket" , and comment the line import
socket from "./solo_socket". Continue if already so.
● In the main project directory run, from terminal, the command mix phx.server .
● Open a browser and run localhost:4000 to access a client.

[Image of the UI](!https://github.com/gauravUFL/Twitter-Clone/blob/main/Screen%20Shot%202020-10-21%20at%201.48.46%20AM.png)
