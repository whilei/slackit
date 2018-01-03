# Ginger

Archives all slack messages for channels she's in to a git repository, and
adds, commits, and pushes to update the remote once in a while.

See https://github.com/whilei/ginger-testland for example of repo she
maintains.

```
HUBOT_SLACK_TOKEN=$HUBOT_SLACK_TOKEN_GINGER ./bin/hubot --adapter slack
```

Possible __ENV_VARS__:
- `GINGER_REPO_PATH`=`/path/to/archive`  This will be automatically made absolute.
- `GINGER_COMMENT_LIMIT`=42  The number of comments to tally before committing and pushing to the remote.

Possible __commands__:
- `ginger push`  If she hears that, she'll `git add . && git commit -m "Ginger update" && git push origin master`, then
reset the comment limit counter.

Her __limitations__:
- She only tracks message she "hears," so if she's offline she won't track those messages she misses.
- She always `git add .` for the whole repo. No changes by channel, or user, or anything like that. Just global.
- She organizes stored messages by channel. That's why the DM's including here are named kind of ugly-ly.
- She won't initialize a git repo or set the remote; you've got to set that stuff
up with something like the following, noting that the remote name __must__ be "origin".

```
cd /path/to/archive
git init
git add . && git commit -m "init"

# Create a remote on Github

git remote add origin https://github.com/you/archive.git
```
