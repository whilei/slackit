# Is a heckler.
# Homunculus = require './homunculus.coffee'
heckles = require './data/heckles.json'

module.exports = (robot) ->

  # Heckles teammates.
  # robot.listen(
  #   (message) -> # Match function
  #     # Occassionally respond to things that Steve says
  #     inhibitions(0.05)
  #   (response) -> # Standard listener callback
  #     # Let Steve know how happy you are that he exists
  #     response.send response.random heckles["#{response.user.name}"]
  # )
  robot.hear /.*/i, (res) ->
    if robot.inhibitions(res, 0.1)
      res.reply res.random heckles["#{res.message.user.name.toLowerCase()}"]

  # Heckles speechifying.
  robot.hear /.*/i, (res) ->
    if res.message.text.length > 200 and robot.inhibitions(res, 0.3)
      res.send res.random heckles.loquacious_people

  # Heckles at liberty.
  robot.hear /.*/i, (res) ->
    if robot.inhibitions(res, 0.05)
      res.reply res.random heckles.willy_nilly


