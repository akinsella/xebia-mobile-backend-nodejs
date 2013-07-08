
index = (req, res) =>
	res.render 'index.ect', { user: req.user }
	return

module.exports =
	index : index
