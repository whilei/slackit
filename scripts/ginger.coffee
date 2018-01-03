# Description
#   Overhears things and tells you how he feels.
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   <ginger push> - Commits and pushes to remote
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Mr. Is <isaac.ardis@gmail.com>

fs = require('fs')
repoLocalPath = './ginger-testland/'
git = require('simple-git')(repoLocalPath)

pushCommentLimit = 10
commentCount = 0

setupUserEnvs = () ->
    userDefinedRepo = process.env.GINGER_REPO_PATH
    if (userDefinedRepo !== '')
        repoLocalPath = userDefinedRepo

    if (process.env.GINGER_COMMENT_LIMIT !== '')
        pushCommentLimit = Number(process.env.GINGER_COMMENT_LIMIT)

addCommitAndPush = () ->
    return git.add('./*').commit("Ginger saved").push(repoRemoteName)

formatMessage = (res) ->
    d = new Date(res.message.rawMessage.ts * 1000).toISOString()
    return "#{d}[#{res.message.user.name}/#{res.message.user.real_name}] #{res.message.text}" + '\n'

existsOrCreate = (path) ->
    fs.statSync(repoLocalPath, (err, stats) ->
        if (err)
            fs.mkdirSync(repoLocalPath)
    )
    # Check if file exists, create if not
    return fs.open(path, 'rs+', (err, fd) ->
        if (err)
            console.error(err)
            return false
        else
            return true
    )

saveMessage = (res) ->
    p = repoLocalPath + res.message.rawMessage.channel.name
    if existsOrCreate(p)
        fs.appendFileSync(p, formatMessage(res))

module.exports = (robot) ->
    setupUserEnvs()

    robot.enter (res) ->
        res.send "I'm here"
    robot.leave (res) ->
        res.send "I'm gone"

    # Likes explosions.
    robot.hear /.*/g, (res) ->
        console.log("got message #{res.message.text}")
        saveMessage(res)
        commentCount++
        if (commentCount > pushCommentLimit)
            addCommitAndPush().then(() -> commentCount = 0)

    robot.hear /^ginger push/g, (res) ->
            addCommitAndPush().then(() ->
                commentCount = 0
                res.send "pushed"
                )
