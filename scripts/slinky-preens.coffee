# Description
#   debug and demystify
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot did I win the lottery <#.##>? - introspect about inhibitions
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Mr. Is <isaac.ardis@gmail.com>

module.exports = (robot) ->

  # Likes random numbers.
  robot.respond /did I win the lottery (\d.\d+)/i, (res) ->
    sponder = ""
    pretend_importance_level = parseFloat(res.match[1])
    sponder += "pretend_importance_level: #{pretend_importance_level}\n"
    peppiness_level = robot.brain.get('pep')
    sponder += "peppiness_level: #{peppiness_level}\n"
    peppiness_level_float = parseFloat(peppiness_level)
    sponder += "peppiness_level_float: #{peppiness_level_float}\n"
    percent_calculated_pep = peppiness_level_float/100.00
    sponder += "percent_calculated_pep: #{percent_calculated_pep}\n"
    calc_pep = percent_calculated_pep*pretend_importance_level
    sponder += "calc_pep: #{calc_pep}\n"
    rand = Math.random()
    sponder += "rand: #{rand}"
    res.send sponder

  # General borkenness computer.
  # By the way this script is loaded first because of the alphabet.
  # This is the last time I write a useless comment to test a git hook.
  # Almost the last time.
  # Come on.
  robot.error (err, res) ->
    robot.logger.error "DOES NOT COMPUTE"

    if res?
      res.reply "DOES NOT COMPUTE"
