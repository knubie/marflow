require 'coffee-script'
cleverbot = require('cleverbot-node')
cleverbot = new cleverbot
irc = require 'irc'
wolfram = require './wolfram'

channels = ['##the_basement']

bot = new irc.Client 'irc.freenode.net', 'Marflow',
  channels: channels

bot.addListener 'message#', (from, to, text, message) ->
  regexs =
    question: /^[?](.*)$/

  if regexs.question.test text # Listen for Wolfram queries.
    query = text.replace /^[?]\s*/g, '' # Extract query.
    wolfram.request query, (answer) ->
      if answer
        bot.say channels[0], answer
      else
        cleverbot.write query, (response) ->
          bot.say channels[0], response.message

