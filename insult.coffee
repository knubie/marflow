fs = require 'fs'
#mongoose = require 'mongoose'
#Schema = mongoose.Schema

words = {}

#exports.wordsSchema = new Schema
  #adjective: []
  #noun: []
  #verb: []
  #nounverb: []

for group in ['adjective', 'noun', 'verb', 'nounverb']
  words[group] = fs.readFileSync("#{group}s.txt", 'utf8').split('\n')
  words[group].pop()

exports.words = words

exports.make = (insultee) ->
  random = (group) ->
    word = words[group][Math.floor(Math.random()*words[group].length)]
  return "#{insultee} is a #{random 'adjective'} #{random 'adjective'} #{random 'noun'}, who #{random 'verb'} #{random 'nounverb'}."

exports.add = (category, word, cb) ->
  if words[category].indexOf word is -1 # Check if word exists in array.
    words[category].push word
    fs.appendFile "#{category}s.txt", "#{word}\n", ->
      cb "Added #{word} to insult #{category}s."
  else
    cb 'Already in list.'
