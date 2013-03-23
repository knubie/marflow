irc = require 'irc'
request = require 'request'
parseString = require('xml2js').parseString
_ = require('underscore')
insult = require('./insult')

CHANNEL = '##test123'

requestingWolfram = false

requestWolfram = (query) ->
  requestingWolfram = true
  request "http://api.wolframalpha.com/v2/query?input=#{encodeURIComponent(query)}&appid=AQLTXA-LU46J2XQ92", (error, response, body) ->
    requestingWolfram = false
    if !error and response.statusCode == 200
      # Convert XML response to json
      parseString body, (error, result) ->
        if result.queryresult.didyoumeans?
          newQuery = result.queryresult.didyoumeans[0].didyoumean[0]._
          requestWolfram(newQuery)
        else
          if result.queryresult.pod?
            for pod, i in result.queryresult.pod
              unless i is 0 or _.isEmpty pod.subpod[0].plaintext[0]
                if typeof(pod.subpod[0].plaintext) is "object"
                  bot.say CHANNEL, pod.subpod[0].plaintext[0].replace(/\s+\|/g, ':').replace(/\n/g, ' | ')
                else
                  bot.say CHANNEL, pod.subpod[0].plaintext.replace(/\s+\|/g, ':').replace(/\n/g, ' | ')
                break
          else
            bot.say CHANNEL, "I don't know."

bot = new irc.Client 'irc.freenode.net', 'Marflow',
  channels: [CHANNEL]

bot.addListener 'message', (from, to, text, message) ->
  # Listen for insult add
  if /^[!]\s*add\s+insult\s+(\S*)\s+(\S*)$/.test text
    message = /^[!]\s*add\s+insult\s+(\w*)\s+(\S*)$/.exec text
    if message[1] is 'adjective' or message[1] is 'noun' or message[1] is 'verb' or message[1] is 'nounverb'
      insult.add message[1], message[2], ->
        bot.say CHANNEL, "Added #{message[2]} to insult #{message[1]}."
  # Listen for insult
  if /^[!]\s*insult\s+(\S+)$/.test text
    nick = /^[!]\s*insult\s+(\S+)$/.exec text
    bot.say CHANNEL, insult.make(nick[1])
  # Listen for messages that begin with a question mark.
  if /^[?](.*)$/.test text
    # Construct the Wolfram|Alpha query by removing the initial
    # question mark and any whitespace.
    if requestingWolfram == true
      bot.say CHANNEL, 'One at a time, please.'
    else
      query = text.replace /^[?]\s*/g, ''
      requestWolfram query
