redis = require './redis'
request = require 'request'

removeParameters = (url, parameters) ->
	for parameter in parameters
		urlparts = url.split('?')

		if urlparts.length >= 2

			urlBase = urlparts.shift() # Get first part, and remove from array
			queryString = urlparts.join("?") # Join it back up

			prefix = encodeURIComponent(parameter) + '='
			pars = queryString.split(/[&;]/g)

			i = pars.length

			i-- # Reverse iteration as may be destructive
			while i > 0
				if pars[i].lastIndexOf(prefix, 0) !=- 1 # Idiom for string.startsWith
					pars.splice(i, 1)
				i--

			result = pars.join('&')
			url = urlBase + if result then '?' + result else ''

	url


getParameterByName = (url, name) ->
	#name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	name = name.replace(/[\[]/, "\\\\[").replace(/[\]]/, "\\\\]")
	regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
	results = regex.exec(url)
	if results == null
		""
	else
		decodeURIComponent(results[1].replace(/\+/g, " "))


sendJsonResponse = (options, data) ->
	callback = getParameterByName(options.req.url, 'callback')
	response = data

	if callback
		options.res.setHeader 'Content-Type', 'application/javascript'
		response = callback + '(' + response + ');'
	else
		options.res.setHeader 'Content-Type', 'application/json'


	console.log "[" + options.url + "] Response sent: " + response
	options.res.send(response)


getContentType = (response) ->
	if response then response.headers["content-type"] else undefined


isContentTypeJsonOrScript = (contentType) ->
	contentType.indexOf('json') >= 0 || contentType.indexOf('script') >= 0


getCacheKey = (req) ->
	removeParameters(req.url, ['callback', '_'])


getUrlToFetch = (req) ->
	removeParameters(req.url, ['callback'])


getIfUseCache = (req) ->
	getParameterByName(req.url, 'cache') == 'false'


useCache = (options) ->
	!options.forceNoCache


responseData = (statusCode, statusMessage, data, options) ->
	if statusCode == 200
		if options.contentType
			options.res.setHeader 'Content-Type', options.contentType

		sendJsonResponse(options, data)
	else
		console.log "Status code: " + statusCode + ", message: " + statusMessage
		options.res.send(statusMessage, statusCode)


getData = (options) ->
	try
		if !useCache(options)
			fetchDataFromUrl(options)
		else
			console.log "[" + options.cacheKey + "] Cache Key is: " + options.cacheKey
			console.log "Checking if data for cache key [" + options.cacheKey + "] is in cache"
			redis.client.get options.cacheKey, (err, data) ->
				if !err && data
					console.log "[" + options.url + "] A reply is in cache key: '" + options.cacheKey + "', returning immediatly the reply"
					options.callback(200, "", data, options)
				else
					console.log "[" + options.url + "] No cached reply found for key: '" + options.cacheKey + "'"
					fetchDataFromUrl(options)
	catch err
		errorMessage = err.name + ": " + err.message
		options.callback(500, errorMessage, undefined, options)


fetchDataFromUrl = (options) ->
	console.log "[" + options.url + "] Fetching data from url"
	request.get {url:options.url, json:true, headers:{"User-Agent":"Xebia-Mobile-Backend"}}, (error, response, data) ->
		contentType = getContentType(response)
		console.log "[" + options.url + "] Http Response - Content-Type: " + contentType
		console.log "[" + options.url + "] Http Response - Headers: ", response.headers

		if !isContentTypeJsonOrScript(contentType)
			console.log "[" + options.url + "] Content-Type is not json or javascript: Not caching data and returning response directly"
			options.contentType = contentType
			options.callback(500, "", undefined, options)
			return
		else
			if options.transform
				data = options.transform data
			jsonData = JSON.stringify(data)
			console.log "[" + options.url + "] Fetched Response from url: " + jsonData
			options.callback(200, "", jsonData, options)
			if useCache(options)
				redis.client.set(options.cacheKey, jsonData)
				redis.client.expire(options.cacheKey, if options.cacheTimeout then options.cacheTimeout else 60 * 60)
				return


buildOptions = (req, res, url, cacheTimeout = 5, transform) ->

	options =
		req: req,
		res: res,
		url: url,
		cacheKey: getCacheKey(req),
		forceNoCache: getIfUseCache(req),
		cacheTimeout: cacheTimeout,
		callback: responseData,
		transform: transform

	options

processRequest = (options) ->
	try
		getData(options)
	catch err
		errorMessage = err.name + ": " + err.message
		responseData(500, errorMessage, undefined, options)

###
Return a random int, used by `utils.uid()`

@param {Number} min
@param {Number} max
@return {Number}
@api private
###
getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min


###
Return a unique identifier with the given `len`.

utils.uid(10);
// => "FDaS435D2z"

@param {Number} len
@return {String}
@api private
###
uid = (len) ->
  buf = []
  chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  charlen = chars.length
  i = 0

  while i < len
    buf.push chars[getRandomInt(0, charlen - 1)]
    ++i
  buf.join ""


module.exports =
	getData: getData,
	responseData: responseData,
	getIfUseCache: getIfUseCache,
	fetchDataFromUrl: fetchDataFromUrl,
	getCacheKey: getCacheKey,
	getUrlToFetch: getUrlToFetch,
	buildOptions: buildOptions,
	processRequest: processRequest,
	getParameterByName: getParameterByName,
	uid: uid
