clients = [{
	id: "1"
	name: "Xebia-iOS"
	clientId: "xebia-ios"
	clientSecret: "1L3J1K4U930J.4LKlk1J4H1J34f!13H4KJ14Hlkj;31"
}]
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