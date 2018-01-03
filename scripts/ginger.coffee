# Description
#   Overhears things and tells you how he feels.
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   <(to|on|for) production> - feelings on launching things
#   <(to|on|for) staging> - feelings on staging things
#   <(to|on|for) staging> - feelings on staging things
#   <government|gov|legal|law|laws> - feelings on government
#   <robot|bot|bastard|computer|wires|tubes> - feelings on robots
#   <update|updates|updated|date> - feelings on dates
#   <meeting|meetings> - feelings on meetings
#   <drink(|s)|beverage(|s)|bev(y|ies)|beer|shot(|s)|whiskey> - feelings on drinks
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Mr. Is <isaac.ardis@gmail.com>

module.exports = (robot) ->

  # Likes explosions.
  robot.hear /.*/g, (res) ->
      res.send "hello"
