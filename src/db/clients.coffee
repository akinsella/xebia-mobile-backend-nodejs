clients = [
	id: "1"
	name: "Samplr"
	clientId: "abc123"
	clientSecret: "ssh-secret"
]
exports.find = (id, done) ->
	i = 0
	len = clients.length

	while i < len
		client = clients[i]
		return done(null, client)  if client.id is id
		i++
	done null, null

exports.findByClientId = (clientId, done) ->
	i = 0
	len = clients.length

	while i < len
		client = clients[i]
		return done(null, client)  if client.clientId is clientId
		i++
	done null, null