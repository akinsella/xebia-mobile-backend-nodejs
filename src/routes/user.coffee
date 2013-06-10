utils = require '../lib/utils'
_ = require('underscore')._

me = (req, res) ->
	  # req.authInfo is set using the `info` argument supplied by
	  # `BearerStrategy`.  It is typically used to indicate scope of the token,
	  # and used in access control checks.  For illustrative purposes, this
	  # example simply returns the scope in the response.
	  res.json
	    user_id: req.user.id
	    name: req.user.name
	    scope: req.authInfo.scope

module.exports =
	me: me
