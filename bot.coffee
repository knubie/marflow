irc = require 'irc'
insult = require './insult'
wolfram = require './wolfram'

CHANNEL = '##test123'

requestingWolfram = false

bot = new irc.Client 'irc.freenode.net', 'Marflow',
  channels: [CHANNEL]

bot.addListener 'message', (from, to, text, message) ->
  # Listen for insult add
  if /^[!]\s*add\s+insult\s+(\S*)\s+(\S*)$/.test text
    message = /^[!]\s*add\s+insult\s+(\w*)\s+(\S*)$/.exec text
    if message[1] is 'adjective' or message[1] is 'noun' or message[1] is 'verb' or message[1] is 'nounverb'
      insult.add message[1], message[2], (msg) ->
        bot.say CHANNEL, msg
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
      requestingWolfram = true
      wolfram.request query, (msg) ->
        requestingWolfram = false
        bot.say CHANNEL, msg
