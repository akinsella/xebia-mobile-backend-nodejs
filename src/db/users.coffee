users = [
	id: "1"
	username: "bob"
	password: "secret"
	name: "Bob Smith"
,
	id: "2"
	username: "joe"
	password: "password"
	name: "Joe Davis"
]
exports.find = (id, done) ->
	i = 0
	len = users.length

	while i < len
		user = users[i]
		return done(null, user)  if user.id is id
		i++
	done null, null

exports.findByUsername = (username, done) ->
	i = 0
	len = users.length

	while i < len
		user = users[i]
		return done(null, user)  if user.username is username
		i++
	done null, null