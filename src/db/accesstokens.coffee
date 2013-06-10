tokens = {}
exports.find = (key, done) ->
	token = tokens[key]
	done null, token

exports.save = (token, userID, clientID, done) ->
	tokens[token] =
		userID: userID
		clientID: clientID

	done null