request = require 'request'
parseString = require('xml2js').parseString
_ = require 'underscore'

exports.request = (query, cb) ->
  request "http://api.wolframalpha.com/v2/query?input=#{encodeURIComponent(query)}&appid=AQLTXA-LU46J2XQ92", (error, response, body) ->
    if !error and response.statusCode == 200
      # Convert XML response to json
      parseString body, (error, result) ->
        if result.queryresult.didyoumeans?
          newQuery = result.queryresult.didyoumeans[0].didyoumean[0]._
          #response "Did you mean #{newQuery}?"
          cb false
        else
          if result.queryresult.pod?
            for pod, i in result.queryresult.pod
              unless i is 0 or _.isEmpty pod.subpod[0].plaintext[0]
                if typeof(pod.subpod[0].plaintext) is "object"
                  cb pod.subpod[0].plaintext[0].replace(/\s+\|/g, ':').replace(/\n/g, ' | ')
                else
                  cb pod.subpod[0].plaintext.replace(/\s+\|/g, ':').replace(/\n/g, ' | ')
                break
          else
            cb false
