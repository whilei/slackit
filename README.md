# Slinky

A real mensch, that [Hubot](https://hubot.github.com)

## [Uses Slack.](https://github.com/irstacks/slinky/blob/master/package.json)
## [Stays awake.](https://registry.npmjs.org/hubot-heroku-keepalive/)
## [Gets in the scrum.](https://github.com/irstacks/slinky/blob/master/scripts/taiga.coffee)
## [Has feelings.](https://github.com/irstacks/slinky/blob/master/scripts/data/feelings.json)
## [Likes to heckle.](https://github.com/irstacks/slinky/blob/master/scripts/data/heckles.json)
## [But has inhibitions.](https://github.com/irstacks/slinky/blob/master/scripts/pep.coffee)
## [Inspects his own brain.](https://nodei.co/npm/hubot-brain-inspect/)
## [Wonders what Toph would tweet.](https://github.com/irstacks/slinky/blob/master/scripts/toph-tweets.coffee)
## [Tweeters.](https://registry.npmjs.org/hubot-tweets/)
## [Is victorious.](https://registry.npmjs.org/hubot-victory/)
## [Makes use of a lot of other people's code.](https://github.com/irstacks/slinky/blob/master/package.json)

----

### Bring slinky to life

1. Clone slinky
2. `npm install`
3. Get heroku toolbelt
4. `heroku create slinky-house`
5. `heroku addons:create rediscloud:30`
6. `heroku config add:HEROKU_URL=https://slinky-house.herokuapp.com`
7. `heroku config:add HUBOT_SLACK_TOKEN=asdfasdfasdfasdfasdfadsf`
12. `heroku config:add TZ="America/New_York"`
8. `heroku config:add HUBOT_HEROKU_KEEPALIVE_URL=https://slinky-house.herokuapp.com`
9. `heroku config:add HUBOT_HEROKU_SLEEP_TIME=23:59`
10. `heroku config:add HUBOT_HEROKU_WAKEUP_TIME=07:30`
11. `heroku addons:create scheduler:standard` and follow curl and timezone directions and whatnot as per the [heroku-keepalive repo](https://github.com/hubot-scripts/hubot-heroku-keepalive) so that your slinky will actually wake up in the morning
11. ... and other env vars if you want to use twitter, taiga, etc.

