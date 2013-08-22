utils = require '../lib/utils'
_ = require('underscore')._

# To be refactored
processRequest = (req, res, url, transform) ->

	options = utils.buildOptions req, res, url, 5 * 60, transform
	utils.processRequest options

	return

repoProps = [
	"id", "name", "full_name", "description", "language",
	"owner", "html_url", "homepage", "has_wiki", "has_issues", "has_downloads",
	"fork", "watchers", "forks", "open_issues", "size", "pushed_at", "created_at", "updated_at"
]

ownerProps = [
	"id", "login", "gravatar_id", "avatar_url"
]

# To be refactored
repos = (req, res) ->

	processRequest req, res, "https://api.github.com/orgs/xebia-france/repos", (data, cb) ->
		_(data).each((repo) ->
			for rKey of repo
				if !(rKey in repoProps) then delete repo[rKey]
				for oKey of repo.owner
					if !(oKey in ownerProps) then delete repo.owner[oKey]
			repo
		)
		cb(undefined, data)


# To be refactored
public_members = (req, res) ->
	processRequest req, res, "https://api.github.com/orgs/xebia-france/public_members", (data, cb) ->
		_(data).each((owner) ->
			for oKey of owner
				if !(oKey in ownerProps) then delete owner[oKey]
			owner
		)
		cb(undefined, data)


module.exports =
	repos : repos,
	public_members : public_members