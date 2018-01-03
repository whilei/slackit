# https://github.com/github/hubot-scripts/blob/master/src/scripts/factoid.coffee
# Description:
#   javabot style factoid support for your hubot. Build a factoid library
#   and save yourself typing out answers to similar questions
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot remember <that?|the?> ___ <is|are|as|equals> ___ - remember stuff (add)
#   hubot remember <that?|the?> ___ also <is|are|as|equals> ___ - remember more stuff (append)
#   hubot what<s|'s| is| are| were| was( the)?> ___ - recall stuff (get)
#   hubot <memory ?> <delete/forget> ___ - forget stuff (delete)
#   hubot no, ___ is ___ - alter memory (update)
#   ___? - chime in if he knows anything about ___?
#   hubot <remember|tell me|list)?> <everything|what do you know|show|> memor(y|ized) - spill the beans
#
# Author:
#   arthurkalm and mr is

class Factoids
  constructor: (@robot) ->
    @robot.brain.on 'loaded', =>
      @cache = @robot.brain.data.factoids
      @cache = {} unless @cache

  add: (key, val) ->
    # "Key is #{key} and val is #{val}"
    input = key
    key = key.toLowerCase() unless @cache[key]?
    if @cache[key]
      "#{input} is already #{@cache[key]}"
    else
      this.setFactoid input, val
      "OK, #{input} is #{val}."

  append: (key, val) ->
    input = key
    key = key.toLowerCase() unless @cache[key]?
    if @cache[key]
      @cache[key] = @cache[key] + ", " + val
      @robot.brain.data.factoids = @cache
      "Ok. #{input} is also #{val} "
    else
      "No memory of #{input}. It can't also be #{val} if it isn't already something."

  setFactoid: (key, val) ->
    input = key
    key = key.toLowerCase() unless @cache[key]?
    @cache[key] = val
    @robot.brain.data.factoids = @cache
    "OK. #{input} is #{val} "

  delFactoid: (key) ->
    input = key
    key = key.toLowerCase() unless @cache[key]?
    delete @cache[key]
    @robot.brain.data.factoids = @cache
    "OK. I forgot about #{input}"

  niceGet: (key) ->
    input = key
    key = key.toLowerCase() unless @cache[key]?
    "#{key} is #{@cache[key]}" or "No memory of #{input}"

  get: (key) ->
    key = key.toLowerCase() unless @cache[key]?
    @cache[key]

  list: ->
    Object.keys(@cache)

  tell: (person, key) ->
    factoid = this.get key
    if @cache[key]
      "#{person}, #{key} is #{factoid}"
    else
      factoid

  handleFactoid: (text) ->
    # Setters.
    if match = /remember+( that)?( the)? (.*) also (is|are|as|equals) (.*)/i.exec text
      thing_to_remember_as = match[3] || match[2]
      thing_to_remember = match[6] || match[5]
      this.append thing_to_remember_as, thing_to_remember
    else if match = /remember+( that)?( the)? (.*) (is|are|as|equals) (.*)/i.exec text
      thing_to_remember_as = match[3] || match[2]
      thing_to_remember = match[5] || match[4]
      this.add thing_to_remember_as, thing_to_remember
    # Getters.
    # else if match = (/^~tell (.+?) about (.+)/i.exec text) or (/^~~(.+) (.+)/.exec text)
    #   this.tell match[1], match[2]
    else if match = /what(s|'s| is| are| were| was)?( the)? ([\w\d\s]+)/i.exec text
      this.niceGet match[match.length-1]

module.exports = (robot) ->
  factoids = new Factoids robot

  # Chimes in if he knows the answer to a key question.
  # But not if he's being smart. (ignore lines starting with , or \s, )
  robot.hear /^(?!\s{0,1},)(.+)\?/i, (msg) ->
    factoid = factoids.get msg.match[1]
    if factoid
      msg.reply msg.match[1] + " is " + factoid

  # Adjust his memory.
  robot.respond /no, (.+) is (.+)/i, (msg) ->
    msg.reply factoids.setFactoid msg.match[1], msg.match[2]

  # Spill the beans.
  robot.respond /(remember|tell me|list)?\b(everything|what do you know|show|) memor(y|ized)/i, (msg) ->
    msg.send factoids.list().join('\n')

  # Remove his memory.
  robot.respond /(memory )?(delete |forget )(.+)/i, (msg) ->
    msg.reply factoids.delFactoid msg.match[msg.match.length-1]

  # Rememberer catcher for implanting and retrieving memories.
  robot.respond /remember|what/i, (res) ->
    # thing_to_remember_as = res.match[3]
    # thing_to_remember = res.match[5]
    res.reply factoids.handleFactoid res.message.text
