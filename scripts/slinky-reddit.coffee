# Description
#   grab a random tweet from a random twit
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   slinky riddle me - get a riddle from reddit
#   slinky <.+> joke|funny - get a joke from reddit
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Mr. Is <isaac.ardis@gmail.com>

feelings = require './data/feelings.json'

module.exports = (robot) ->

  # Is slow.
  robot.respond /you are a little slow|you're a little slow/i, (res) ->
    setTimeout () ->
      res.send "Who you calling 'slow'?"
    , 60 * 1000

  # Riddlers.
  robot.respond /riddle me/i, (msg) ->
    url = "riddles"
    msg.http("http://www.reddit.com/r/#{url}.json")
    .get() (err, res, body) ->
      try
        data = JSON.parse body
        children = data.data.children
        joke = msg.random(children).data

        joketext = joke.title.replace(/\*\.\.\.$/,'') + ' ' + joke.selftext.replace(/^\.\.\.\s*/, '')

        msg.send "Alright. It goes like this:\n" + joketext.trim()

      catch ex
        msg.send "Erm, something went EXTREMELY wrong - #{ex}"

  # Jokers.
  robot.respond /.+(joke|funny)/i, (msg) ->
    url = "jokes"
    msg.http("http://www.reddit.com/r/#{url}.json")
    .get() (err, res, body) ->
      try
        data = JSON.parse body
        children = data.data.children
        joke = msg.random(children).data

        joketext = joke.title.replace(/\*\.\.\.$/,'') + ' ' + joke.selftext.replace(/^\.\.\.\s*/, '')

        msg.send "A joke?!\nI got a good one: " + joketext.trim()

      catch ex
        msg.send "Erm, something went EXTREMELY wrong - #{ex}"
