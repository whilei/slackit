module.exports = (robot) ->

  getPep = (res) ->
    pep = robot.brain.get('pep')
    if pep is undefined
      res.send "You've got to set my pep level!"
      return
    else
      return pep

  robot.inhibitions = (res, importanceBias) ->
    peppiness_level = parseFloat(getPep(res))
    calculated_pep = peppiness_level/100.0*importanceBias
    rand = Math.random()
    if rand < calculated_pep # ie 50/100 * .8
      # console.log "Chances were " + rand + "would be < " + calculated_pep
      return true
    else
      return false
