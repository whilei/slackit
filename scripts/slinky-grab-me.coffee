# Description
#   Custom giffers.
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot grab me (miyagi|what) - grab miyagi, or what???
#   hubot pomp pomp - crazy muthafuckin awesome kid
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Mr. Is <isaac.ardis@gmail.com>

areteh_base = process.env.HUBOT_ARETEH_SLINKY_URL

module.exports = (robot) ->

  robot.respond /grab me (.*)/i, (res) ->
    wants = res.match[1] # (miyagi|what)
    res.send "#{areteh_base}/#{wants}.gif"

  robot.respond /pomp pomp/i, (res) ->
    res.send "#{areteh_base}/who-is-that-kid-hes-awesome.gif"
