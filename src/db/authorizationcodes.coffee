codes = {}

exports.find = (key, done) ->
  code = codes[key]
  done null, code

exports.save = (code, clientID, redirectURI, userID, done) ->
  codes[code] =
    clientID: clientID
    redirectURI: redirectURI
    userID: userID

  done null