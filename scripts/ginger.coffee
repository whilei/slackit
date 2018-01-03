# Description
#   Silently listens and records all conversations she's invited to a git repo,
#   and pushes commits to Github repo on the reg.
#
# Configuration:
#   GINGER_COMMENT_LIMIT
#   GINGER_REPO_PATH
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
resolve = require('path').resolve
join = require('path').join
repoLocalPath = './ginger-testland/'
git = require('simple-git')(repoLocalPath)

pushCommentLimit = 100
commentCount = 0

addCommitAndPush = (user, isHuman) ->
    # If ginger is automatically updating, use her given robot name.
    if (!isHuman)
        return git.add('./*').commit("#{user} update").push('origin')
        # Otherwise add user who sent message as author to commit with Ginger/robot-name.
    return git.add('./*').commit("update", {'--author': '"' + user + '"'}).push('origin')

formatMessage = (res) ->
    d = new Date(res.message.rawMessage.ts * 1000).toISOString()
    return "#{d}[#{res.message.user.name}/#{res.message.user.real_name}] #{res.message.text}" + '\n'

existsOrCreate = (path) ->
    if (fs.existsSync(repoLocalPath) == false)
        fs.mkdirSync(repoLocalPath,0o777)
    if (fs.existsSync(path) == false)
        fs.openSync(path, 'a') # 'a' - Open file for appending. The file is created if it does not exist.
    if (fs.existsSync(path) == false)
        return false
    return true

saveMessage = (res) ->
    p = join(repoLocalPath, res.message.rawMessage.channel.name)
    haveP = existsOrCreate(p)
    if (haveP)
        fs.appendFileSync(p, formatMessage(res))
    else
        console.log("could not create or ensure file", p)

module.exports = (robot) ->

    pushCommentLimit = process.env.GINGER_COMMENT_LIMIT || pushCommentLimit
    pushCommentLimit = Number(pushCommentLimit)
    repoLocalPath = process.env.GINGER_REPO_PATH || repoLocalPath
    repoLocalPath = resolve(repoLocalPath)

    console.log("Push comment limit", pushCommentLimit)
    console.log("Repo local path", repoLocalPath)

    git.addConfig("user.name", "Ginger").addConfig("user.email", "job@etcdevteam.com")

    robot.hear /.*/g, (res) ->
        console.log("got message #{res.message.text}")
        saveMessage(res)
        commentCount++
        if (commentCount > pushCommentLimit)
            addCommitAndPush(robot.name, false).then(() -> commentCount = 0)

    robot.hear /^ginger push$/g, (res) ->
            addCommitAndPush(res.message.user.name+' '+'<'+res.message.user.profile.email+'>', true).then(() ->
                commentCount = 0
                res.send "pushed"
                )
