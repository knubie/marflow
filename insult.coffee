fs = require 'fs'

words = {}

for group in ['adjective', 'noun', 'verb', 'nounverb']
  words[group] = fs.readFileSync("#{group}s.txt", 'utf8').split('\n')
  words[group].pop()

exports.words = words

exports.make = (insultee) ->
  random = (group) ->
    word = words[group][Math.floor(Math.random()*words[group].length)]
  return "#{insultee} is a #{random 'adjective'} #{random 'adjective'} #{random 'noun'}, who #{random 'verb'} #{random 'nounverb'}."

exports.add = (category, word, cb) ->
  if words[category].indexOf word is -1
    words[category].push word
    fs.appendFile "#{category}s.txt", "#{word}\n", (error) ->
      throw error if error
      cb "Added #{word} to insult #{category}s."
  else
    cb 'Already in list.'
