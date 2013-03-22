irc = require 'irc'
fs = require 'fs'
request = require 'request'
parseString = require('xml2js').parseString
_ = require('underscore')

CHANNEL = '##the_basement'
ADJECTIVES = []
fs.readFile 'adjectives.txt', 'utf8', (error, data) ->
  ADJECTIVES = data.split('\n')
  ADJECTIVES.pop()
NOUNS = []
fs.readFile 'nouns.txt', 'utf8', (error, data) ->
  NOUNS = data.split('\n')
  NOUNS.pop()

VERBS = []
fs.readFile 'verbs.txt', 'utf8', (error, data) ->
  VERBS = data.split('\n')
  VERBS.pop()

NOUNVERBS = []
fs.readFile 'nounverbs.txt', 'utf8', (error, data) ->
  NOUNVERBS = data.split('\n')
  NOUNVERBS.pop()

setInsult = ->
  insult = ""
  for i in [1..2]
    adjSpot = Math.floor(Math.random()*ADJECTIVES.length)
    insult = insult + ADJECTIVES[adjSpot] + ' '
  nounSpot = Math.floor(Math.random()*NOUNS.length)
  insult = insult + NOUNS[nounSpot]
  verbSpot = Math.floor(Math.random()*VERBS.length)
  insult = insult + " who " + VERBS[verbSpot]
  nounverbSpot = Math.floor(Math.random()*NOUNVERBS.length)
  insult = insult + " " + NOUNVERBS[nounverbSpot] + '.'
  return insult

requestWolfram = (query) ->
  request "http://api.wolframalpha.com/v2/query?input=#{encodeURIComponent(query)}&appid=AQLTXA-LU46J2XQ92", (error, response, body) ->
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
                  bot.say CHANNEL, pod.subpod[0].plaintext[0]
                else
                  bot.say CHANNEL, pod.subpod[0].plaintext
                break
          else
            bot.say CHANNEL, "I don't know."

bot = new irc.Client 'irc.freenode.net', 'Marflow',
  channels: [CHANNEL]

bot.addListener 'message', (from, to, text, message) ->
  # Listen for insult add
  if /^[!]\s*add\s+insult\s+(\S*)\s+(\S*)$/.test text
    command = /^[!]\s*add\s+insult\s+(\w*)\s+(\S*)$/.exec text
    if command[1] is 'adjective'
      fs.appendFile 'adjectives.txt', "#{command[2]}\n", (error) ->
        if ADJECTIVES.indexOf command[2] is -1
          ADJECTIVES.push command[2]
          bot.say CHANNEL, "Added #{command[2]} to insult adjectives."
          throw error if error
    if command[1] is 'noun'
      fs.appendFile 'nouns.txt', "#{command[2]}\n", (error) ->
        if NOUNS.indexOf command[2] is -1
          NOUNS.push command[2]
          bot.say CHANNEL, "Added #{command[2]} to insult nouns."
          throw error if error
    if command[1] is 'verb'
      fs.appendFile 'verbs.txt', "#{command[2]}\n", (error) ->
        if VERBS.indexOf command[2] is -1
          VERBS.push command[2]
          bot.say CHANNEL, "Added #{command[2]} to insult verbs."
          throw error if error
    if command[1] is 'nounverb'
      fs.appendFile 'nounverbs.txt', "#{command[2]}\n", (error) ->
        if NOUNVERBS.indexOf command[2] is -1
          NOUNVERBS.push command[2]
          bot.say CHANNEL, "Added #{command[2]} to insult nounverbs."
          throw error if error
    
  # Listen for insult
  if /^[!]\s*insult\s+(\S+)$/.test text
    nick = /^[!]\s*insult\s+(\S+)$/.exec text
    bot.say CHANNEL, nick[1] + " is a " + setInsult()
  # Listen for messages that begin with a question mark.
  if /^[?](.*)$/.test text
    # Construct the Wolfram|Alpha query by removing the initial
    # question mark and any whitespace.
    query = text.replace /^[?]\s*/g, ''
    requestWolfram query
