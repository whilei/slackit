# https://github.com/github/hubot-scripts/blob/master/src/scripts/cleverbot.coffee
# Description:
#   "Makes your Hubot even more Clever™"
#
# Dependencies:
#   "cleverbot-node": "0.2.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot , <input> - slinky the human will chat with you
#
# Author:
#   ajacksified
#   Stephen Price <steeef@gmail.com>

cleverbot = require('cleverbot-node')

module.exports = (robot) ->
  c = new cleverbot()

  robot.respond /, (.*)/i, (msg) ->
    data = msg.match[1].trim()
    cleverbot.prepare(( -> c.write(data, (c) => msg.reply(c.message))))
