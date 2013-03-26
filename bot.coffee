irc = require 'irc'
#mongoose = require 'mongoose'
#insult = require './insult'
wolfram = require './wolfram'

#mongoose.connect 'mongodb://localhost/test
#db = mongoose.connection
#mongoose.on 'error', console.error.bind('console', 'connection error:')
#db.once 'open' ->
  #console.log 'Connected to mongo!'

channels = ['##the_basement']

bot = new irc.Client 'irc.freenode.net', 'Marflow',
  channels: channels

bot.addListener 'message', (from, to, text, message) ->
  regexs =
    addInsult: /^[!]\s*add\s+insult\s+(\w*)\s+(\S*)$/
    insult: /^[!]\s*insult\s+(\S+)$/
    question: /^[?](.*)$/

  #if regexs.addInsult.test text # Listen for add insult word.
    #message = regexs.addInsult.exec text
    #for category in ['adjective', 'noun', 'verb', 'nounverb']
      ## message[1] => Category.
      ## message[2] => Word to be added.
      #if message[1] is category
        #insult.add message[1], message[2], (confirmation) ->
          #bot.say channels[0], confirmation
  #if regexs.insult.test text # Listen for insult.
    #insultee = regexs.insult.exec text # Capture insultee.
    #bot.say channels[0], insult.make(insultee[1])
  if regexs.question.test text # Listen for Wolfram queries.
    query = text.replace /^[?]\s*/g, '' # Extract query.
    wolfram.request query, (answer) ->
      bot.say channels[0], answer
