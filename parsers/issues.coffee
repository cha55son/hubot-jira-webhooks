
module.exports = 
    parse: (msg) ->
        'testing webhooks'
    can_parse: (event_name) ->
       [
           'jira:issue_created', 'jira:issue_updated', 
           'jira:issue_deleted', 'jira:worklog_updated'
       ].indexOf(event_name) != -1
