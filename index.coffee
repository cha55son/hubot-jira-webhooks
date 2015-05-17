fs = require 'fs'
path = require 'path'

console.log "Started hubot-jira-webhooks/index.coffee"

module.exports = (robot, scripts) ->
  scriptsPath = path.resolve(__dirname, 'src', 'scripts')
  fs.exists scriptsPath, (exists) ->
    return unless exists
    for script in fs.readdirSync(scriptsPath)
      if scripts? and '*' not in scripts
        robot.loadFile(scriptsPath, script) if script in scripts
      else
        robot.loadFile(scriptsPath, script)
