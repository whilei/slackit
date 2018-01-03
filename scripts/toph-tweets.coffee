# Description
#   grab a random tweet from a random twit
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   wwtt? - grab a random tweet from toph's last 100 tweets
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Mr. Is <isaac.ardis@gmail.com>

Twit = require 'twit'

config =
  consumer_key: process.env.HUBOT_TWITTER_CONSUMER_KEY
  consumer_secret: process.env.HUBOT_TWITTER_CONSUMER_SECRET
  access_token: process.env.HUBOT_TWITTER_ACCESS_TOKEN
  access_token_secret: process.env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET

twit = undefined

getTwit = ->
  unless twit
    twit = new Twit config
  return twit

whatWouldTophTweet = (msg) ->
  username = 'tophtucker' #msg.match[2]

  twit = getTwit()
  count = 100
  searchConfig =
    screen_name: username,
    count: count

  twit.get 'statuses/user_timeline', searchConfig, (err, statuses) ->
    return msg.send "Error retrieving tweets!" if err
    return msg.send "No results returned!" unless statuses?.length

    # get tweet that is not talking directly to someone or RT-ing
    random_tweet = ""
    random_index = 0
    caught_statuses_length = statuses.length
    # pattern = /^(\@|RT)/i # text begins with @
    pattern = /^(asdfasdf)/i

    getARandomTophTweet = ->
      random_index = Math.floor(Math.random() * statuses.length)
      random_tweet = statuses[random_index]

    # if at first you don't succeed...
    getARandomTophTweet()

    # try try again
    while random_tweet.text.match pattern
      if random_tweet.text.match pattern
        getARandomTophTweet()
      else
        break

    return msg.send "Number #{random_index} from Toph's last #{caught_statuses_length} tweets ->\n#{random_tweet.text}"

module.exports = (robot) ->

  # What would toph tweet.
  robot.hear /wwtt\?/i, (msg) ->
    whatWouldTophTweet(msg)
