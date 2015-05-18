# Description:
#   Handle webhooks from JIRA.
#
# Dependencies:
#   None
#
# Configuration:
#   JIRA_HOST_URL     - The URL to your JIRA instance. ex. http://<hostname>
#   JIRA_ROOM_SUFFIX  - To be appended to the end of the roomname. 
#                       Ex. roomname        = webapps 
#                           roomname_suffix = @conference.digitalreasoning.com
#                           full_roomname   = webapps@conference.digitalreasoning.com
#
# Commands:
#   None
#
# Author:
#   Chason Choate (cha55son)

fs = require 'fs'
parsers = []

do () ->
    path = __dirname + '/parsers'
    for script in fs.readdirSync(path)
        full_path = path + '/' + script
        parser = require(full_path)
        parser.path = full_path
        parsers.push parser

module.exports = (robot) ->
    jira_url = process.env.JIRA_HOST_URL
    room_suffix = process.env.JIRA_ROOM_SUFFIX

    robot.router.post '/jira/webhooks/:room', (req, res) ->
        room = req.params.room

        # Parse the JSON and build the message object
        msg = false
        try 
            json = JSON.stringify(req.body)
            msg = JSON.parse json
            unless process.env.DEBUG
                robot.logger.info "Received jira message:"
                robot.logger.info json
        catch e
            robot.logger.error "Failed to parse JSON from JIRA webhook (#{e.toString()})"
        return unless msg

        # Determine which parser will parse the message
        parser = false
        parsers.forEach (a_parser) ->
            parser = a_parser if a_parser.can_parse(msg.webhookEvent)
        unless parser
            return robot.logger.warning "No parsers can parse: #{msg.webhookEvent}."

        # Obtain the payload (string) from the parser.
        payload = false
        try
            payload = parser.parse(msg)
        catch e
            robot.logger.error "Parser (#{parser.path}) failed to parse message."
            robot.logger.error e.toString()
        return unless payload

        # Build the user object and send the message.
        user = robot.brain.userForId 'broadcast'
        user.room = room + room_suffix
        user.type = 'groupchat'
        robot.send user, payload
        
        res.writeHead 200, { 'Content-Type': 'text/plain' }
        res.end 'Thanks'
