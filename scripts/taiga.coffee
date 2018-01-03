# Description:
#   Send Taiga.io commands via hubot
#
# Dependencies:
#   none
#
# Configuration:
#   HUBOT_TAIGA_USERNAME
#   HUBOT_TAIGA_PASSWORD
#   HUBOT_TAIGA_PROJECT
#   HUBOT_TAIGA_URL
#
# Commands:
#   taiga-<REF> <comment> - Create a comment. Example `TG-123 I left a comment!` and `TG-123 #done I finished it, I am the best.`
#   taiga (us|userstory|userstories|task|tasks) - List all open userstories or tasks.
#   taiga (task|tasks) us:<ID> - List all tasks for userstory by ID, e.g. taiga tasks us:553311
#   taiga auth <username> <password> - Authenticate so that comments from from this user
#   taiga create (us|userstory) sub:The beginning of long journey desc:The Road goes on.
#   taiga create (task|tasks) (us:553311|) subj:Do it. desc:And do it good. - Add task, optionally specifying userstory ID.
#   taiga delete (us|userstory|task):(id) - Delete task or userstory by ID.
#   taiga info - Displays infomation about Taiga connection for user
#   taiga project <project-slug> - Set taiga project for this channel
#
#
# Notes:
#   Environment variables are optional.
#   If you use tree.taiga.io and wish to have each user log in as themselves - there is no need to set them
#
#   Set username and password if you would rather have a Hubot user submit for all users
#   If you want users to post as themselves they should use `taiga auth <username> <password>`.
#   Consider the security implications of having password set in your chat service.
#
#   Set project if you would like a global default project set.
#   Otherwise use `taiga project <project-slug>` to set the project per channel
#
# Author:
#   Mostly David Burke and some Isaac


module.exports = (robot) ->

####### Helpers and init inherited from Mr. Burke.

  username = process.env.HUBOT_TAIGA_USERNAME
  password = process.env.HUBOT_TAIGA_PASSWORD
  global_project = process.env.HUBOT_TAIGA_PROJECT
  project_not_set_msg = "Set project with `taiga project PROJECT_SLUG`"
  url = process.env.HUBOT_TAIGA_URL or "https://api.taiga.io/api/v1/"
  taiga_tree_url = "https://tree.taiga.io/project/"
  redis_prefix = 'taiga_'
  statusPattern = /(#[^\s]+)/i


  getProject = (msg) ->
    key = getProjectKey(msg)
    project = robot.brain.get(key)
    if project
      project
    else
      global_project


  getUserToken = (msg) ->
    key = "#{redis_prefix}#{msg.message.user.name}_token"
    token = robot.brain.get(key)
    if token
      token


  getProjectKey = (msg) ->
    project_key = redis_prefix + 'project'
    room = msg.message.room
    project_key + room



########################### DELETE

  robot.hear /taiga delete (us|userstory|task):(\d+)/i, (msg) ->
    resource_type = msg.match[1]
    rid = msg.match[2]

    switch resource_type
      when 'us','userstory'
        resource_path = 'userstories'
      when 'task'
        resource_path = 'tasks'


    token = getUserToken(msg)

    if token
      deleteResource(msg, token, resource_path, rid)
    else
      data = JSON.stringify({
        type: "normal",
        username: username,
        password: password
      })
      robot.http(url + 'auth')
        .headers('Content-Type': 'application/json')
        .post(data) (err, res, body) ->
          data = JSON.parse body
          token = data.auth_token
          if token
            deleteResource(msg, token, resource_path, rid)
          else
            msg.send "Unable to authenticate"

  deleteResource = (msg, token, resource_path, rid) ->
    data = "#{resource_path}/"
    auth = "Bearer #{token}"

    robot.http(url + data + rid)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .delete() (err, res, body) ->
        #if res is '204 NO CONTENT'
        if not err
          msg.send "Deleted resource."
        else
          msg.send "Could not delete the resource."



########################### POST

  # Post a task or userstory.
  # If posting a task, us:<id> is optional.
  # Argument order is not optional.
  robot.hear /taiga create (us|userstory|userstories|task|tasks)( us\:(\d+))? (subj:(.*)) (desc:(.*))/i, (msg) ->
    resource_type = msg.match[1]
    incoming_us = msg.match[3]
    incoming_subject = msg.match[5]
    incoming_description = msg.match[7]

    payload = {
      subject: incoming_subject,
      description: incoming_description
    }

    switch resource_type
      when 'us','userstory','userstories'
        resource_url = '/userstories'
        gettable_url = 'us'
      when 'task','tasks'
        resource_url = '/tasks'
        gettable_url = 'tasks'

    # Set us ref if there is one and if we're not posting a user story.
    payload.user_story = parseInt(incoming_us) if incoming_us and resource_url is '/tasks'

    project = getProject(msg)
    if not project
      msg.send project_not_set_msg
      return

    token = getUserToken(msg)

    if token
      postResource(msg, token, project, resource_url, gettable_url, payload)
    else
      data = JSON.stringify({
        type: "normal",
        username: username,
        password: password
      })
      robot.http(url + 'auth')
        .headers('Content-Type': 'application/json')
        .post(data) (err, res, body) ->
          data = JSON.parse body
          token = data.auth_token
          if token
            postResource(msg, token, project, resource_url, gettable_url, payload)
          else
            msg.send "Unable to authenticate"

  postResource = (msg, token, projectSlug, resource_url, gettable_url, payload) ->
    # Use for grabbing resolved project id.
    data = "?project=#{projectSlug}"
    auth = "Bearer #{token}"

    # Get project id.
    robot.http(url + 'resolver' + data)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .get() (err, res, body) ->
        data = JSON.parse body
        pid = data.project

        # If we resolve the project id.
        if pid
          payload.project = pid
          postable_json = JSON.stringify payload

          robot.http(url + resource_url)
            .headers('Content-Type': 'application/json', 'Authorization': auth)
            .post(postable_json) (err, res, body) ->
              reference = JSON.parse body
              if err or not reference.id
                msg.send "Failed to create the resource."
              else
                switch gettable_url
                  when 'us' then typer = "userstory"
                  when 'tasks' then typer = "task"
                msg.send "Created #{typer} *#{payload['subject']}*\n#{taiga_tree_url}#{getProject(msg)}/#{gettable_url}/#{reference.ref}"
        else
          msg.send "Couldn't get the pid."


#################### INDEX


  # Get all tasks or userstories.
  robot.hear /taiga (us|userstory|userstories|task|tasks)$/i, (msg) ->
    project = getProject(msg)
    if not project
      msg.send project_not_set_msg
      return

    resource_type = msg.match[1]

    switch resource_type
      when 'us','userstory','userstories'
        resource_path = '/userstories'
      when 'task','tasks'
        resource_path = '/tasks'

    token = getUserToken(msg)

    if token
      getAllResource(msg, token, project, resource_path)
    else
      data = JSON.stringify({
        type: "normal",
        username: username,
        password: password
      })
      robot.http(url + 'auth')
        .headers('Content-Type': 'application/json')
        .post(data) (err, res, body) ->
          data = JSON.parse body
          token = data.auth_token
          if token
            getAllResource(msg, token, project, resource_path)
          else
            msg.send "Unable to authenticate"


  getAllResource = (msg, token, projectSlug, resource_path) ->
    data = "?project=#{projectSlug}"
    auth = "Bearer #{token}"

    # Get project id.
    robot.http(url + 'resolver' + data)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .get() (err, res, body) ->
        data = JSON.parse body
        pid = data.project
        if pid
          # Get list userstories/tasks for project where status_is_closed=false.
          data = "?project=#{pid}&status__is_closed=false"
          robot.http(url + resource_path + data)
            .headers('Content-Type': 'application/json', 'Authorization': auth)
            .get() (err, res, body) ->
              response_list = JSON.parse body

              if response_list

                say = "*Open Userstories:*\n" if resource_path is '/userstories'
                say = "*Open Tasks:*\n" if resource_path is '/tasks'

                say += formatted_reponse(item, projectSlug, resource_path) for item in response_list
                msg.send say

              else
                msg.send "Couldn't get data for project with id #{pid}."
        else
          msg.send "Couldn't get the pid."

  # Get all tasks for specific userstory.
  # Now accepting US:id.
  # https://api.taiga.io/api/v1/tasks/by_ref?ref=1&project=1
  robot.hear /taiga (task|tasks) us:(\d+)/i, (msg) ->

    usid = msg.match[2]
    project = getProject(msg)
    if not project
      msg.send project_not_set_msg
      return

    token = getUserToken(msg)

    if token
      getTasksForUserstory(msg, token, project, usid)
    else
      data = JSON.stringify({
        type: "normal",
        username: username,
        password: password
      })
      robot.http(url + 'auth')
        .headers('Content-Type': 'application/json')
        .post(data) (err, res, body) ->
          data = JSON.parse body
          token = data.auth_token
          if token
            getTasksForUserstory(msg, token, project, usid)
          else
            msg.send "Unable to authenticate"


  getTasksForUserstory = (msg, token, projectSlug, usid) ->
    data = "?project=#{projectSlug}"
    auth = "Bearer #{token}"

    # Get project id.
    robot.http(url + 'resolver' + data)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .get() (err, res, body) ->
        data = JSON.parse body
        pid = data.project
        if pid

          data = "?user_story=#{usid}&status__is_closed=false" # "/"
          auth = "Bearer #{token}"

          robot.http(url + 'tasks' + data)
            .headers('Content-Type': 'application/json', 'Authorization': auth)
            .get() (err, res, body) ->

              if not err
                task_list = JSON.parse body
                # body = JSON.stringify body
                # msg.send body

                if task_list
                  # if task_list.length > 0
                  say = "*Task list for US:#{usid}*\n"
                  say += formatted_reponse(task, projectSlug, '/tasks') for task in task_list
                  msg.send say
                  # else
                  #   msg.send "There are no tasks for US:#{usid}"

                else
                  msg.send "Unable to retrieve tasks for userstory w/ id: #{usid}"

              # There was an err.
              else if err
                say = "There was an error: "
                say += "#{err}"
                msg.send say


  formatted_reponse = (item, projectSlug, resource_path) ->
    words = ""

    switch resource_path
      when '/userstories'

        words += "\n"
        words += "us:" + item['id']
        words += " #" + item['ref']
        words += " _" + item['status_extra_info']['name'] + "_ "
        words += "(" + item['assigned_to_extra_info']['full_name_display'] + ")" if item['assigned_to_extra_info']
        words += " - "
        words += "*" + item['subject'] + "* "
        words += "\n_" + item['description'] + "_" if item['description']
        # Link to taiga item.
        words += "\n#{taiga_tree_url}#{projectSlug}/us/#{item['ref']}\n"

      when '/tasks'

        words += "\n_"
        words += "us:" + (item['user_story'] || "??????") + "/task:" + item['id']
        words += " #" + item['ref']
        words += " " + item['status_extra_info']['name'] + "_ "
        words += " - "
        words += "*" + item['subject'] + "* "
        words += "\n_" + item['description'] + "_" if item['description']
        words += "\n#{taiga_tree_url}#{projectSlug}/task/#{item['ref']}\n"

    return words


############################# D Burke


  robot.hear /taiga info/i, (msg) ->
    project = getProject(msg)
    if project
      msg.send "Taiga project for #{msg.message.room} is #{project}"
    else
      msg.send "No Taiga project set for #{msg.message.room}."
      msg.send project_not_set_msg
    msg.send "Using #{username} for username"
    if password
      msg.send "Password is set"
    else
      msg.send "Password isn't set"
    msg.send "You are #{msg.message.user.name}"
    token = getUserToken(msg)
    if token
      msg.send "You are logged in - comments will be posted by your Taiga user"
    else
      msg.send "You are not logged in. You can post comments as yourself by logging in with `taiga auth username password.`"


  robot.hear /taiga project (.*)/i, (msg) ->
    project_slug = msg.match[1]
    key = getProjectKey(msg)
    robot.brain.set key, project_slug
    msg.send "Set room #{msg.message.room} to use project #{project_slug}"

  robot.hear /taiga auth (.*) (.*)/i, (msg) ->
    username = msg.match[1]
    password = msg.match[2]
    data = JSON.stringify({
      type: "normal",
      username: username,
      password: password
    })
    robot.http(url + 'auth')
      .headers('Content-Type': 'application/json')
      .post(data) (err, res, body) ->
        data = JSON.parse body
        token = data.auth_token
        if token
          key = "#{redis_prefix}#{msg.message.user.name}_token"
          robot.brain.set key, token
          msg.send "Authenication to Taiga.io successful"
        else
          msg.send "Authentication Failed"


  robot.hear /taiga-(\d*) (.*)/i, (msg) ->
    project = getProject(msg)
    if not project
      msg.send project_not_set_msg
      return

    tid = msg.match[1]
    payload = msg.match[2]
    token = getUserToken(msg)

    if token
      submitComment(msg, token, project, tid, payload)
    else
      data = JSON.stringify({
        type: "normal",
        username: username,
        password: password
      })
      robot.http(url + 'auth')
        .headers('Content-Type': 'application/json')
        .post(data) (err, res, body) ->
          data = JSON.parse body
          token = data.auth_token
          if token
            submitComment(msg, token, project, tid, payload)
          else
            msg.send "Unable to authenticate"

  submitComment = (msg, token, projectSlug, tid, payload) ->
    chatUsername = msg.message.user.name
    comment = "#{chatUsername}: #{payload}"
    auth = "Bearer #{token}"
    data = "?project=#{projectSlug}&us=#{tid}"
    robot.http(url + 'resolver' + data)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .get() (err, res, body) ->
        data = JSON.parse body
        us = data.us

        if us
          project = data.project
          sendReference(msg, auth, us, comment, project, "user story")
        else
          checkIfIssue(msg, auth, tid, comment, projectSlug)


  checkIfIssue = (msg, auth, tid, comment, projectSlug) ->
    data = "?project=#{projectSlug}&issue=#{tid}"
    robot.http(url + 'resolver' + data)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .get() (err, res, body) ->
        data = JSON.parse body
        issue = data.issue

        if issue
          project = data.project
          sendReference(msg, auth, issue, comment, project, "issue")
        else
          checkIfTask(msg, auth, tid, comment, projectSlug)


  checkIfTask = (msg, auth, tid, comment, projectSlug) ->
    data = "?project=#{projectSlug}&task=#{tid}"
    robot.http(url + 'resolver' + data)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .get() (err, res, body) ->
        data = JSON.parse body
        task = data.task

        if task
          project = data.project
          sendReference(msg, auth, task, comment, project, "task")
        else
          msg.send "Couldn't find TG REF #{tid}"


  sendReference = (msg, auth, reference, comment, project, type) ->
    switch type
      when "user story" then fullUrl = url + 'userstories/' + reference
      when "issue" then fullUrl = url + 'issues/' + reference
      when "task" then fullUrl = url + 'tasks/' + reference

    robot.http(fullUrl)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .get() (err, res, body) ->
        data = JSON.parse body
        version = data.version
        data = {
          "comment": comment,
          "version": version
        }
        match = statusPattern.exec(comment)
        if match
          statusSlug = match[1].slice(1)
          getReferenceStatuses(msg, auth, reference, project, statusSlug, data, type)
        else
          postReference(msg, auth, reference, data, type, statusSlug)


  getReferenceStatuses = (msg, auth, reference, project, statusSlug, data, type) ->
    switch type
      when "user story" then fullUrl = "#{url}userstory-statuses?project=#{project}"
      when "issue" then fullUrl = "#{url}issue-statuses?project=#{project}"
      when "task" then fullUrl = "#{url}task-statuses?project=#{project}"

    robot.http(fullUrl)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .get() (err, res, body) ->
        statuses = JSON.parse body
        for status in statuses
          if status.slug == statusSlug
            data.status = status.id
        if data.status
          postReference(msg, auth, reference, data, type, statusSlug)
        else
          msg.send "Unable to find #{type} status #{statusSlug}."


  postReference = (msg, auth, reference, data, type, statusSlug) ->
    data = JSON.stringify(data)

    switch type
      when "user story" then fullUrl = url + 'userstories/' + reference
      when "issue" then fullUrl = url + 'issues/' + reference
      when "task" then fullUrl = url + 'tasks/' + reference

    robot.http(fullUrl)
      .headers('Content-Type': 'application/json', 'Authorization': auth)
      .patch(data) (err, res, body) ->
        reference = JSON.parse body
        if err or not reference.id
          msg.send "Failed to update #{type}"
        else
          msg.send "Comment added. Status for #{type} ##{reference.ref} is #{statusSlug}"
