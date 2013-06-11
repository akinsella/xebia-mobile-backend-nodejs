CacheEntry = require '../model/cacheEntry'
moment = require 'moment'

get = (key, callback) ->
	CacheEntry.findOne { key: key }, (err, cacheEntry) ->
		if (err || !cacheEntry)
			if (callback)
				callback(err, undefined)
		else
			now = moment()
			lastModified = moment(cacheEntry.lastModified)
			lastModifiedWithTtl = lastModified.add('seconds', cacheEntry.ttl)
			if (now.isAfter(lastModifiedWithTtl))
				cacheEntry.remove()
				if (callback)
					callback(err, undefined)
			else
				if (callback)
					callback(err, cacheEntry.data)


set = (key, data, ttl, callback) ->
	cacheEntry = new CacheEntry({ key:key, data:data, ttl:ttl })
	cacheEntry.save (err) ->
		if (callback)
			callback(err, if cacheEntry then cacheEntry.data else undefined)

remove = (key, callback) ->
	CacheEntry.findOneAndRemove { key: key }, (err, cacheEntry) ->
		if (callback)
			callback(err, cacheEntry)

clear = (callback) ->
	CacheEntry.findAndRemove { }, (err) ->
		if (callback)
			callback(err)

module.exports =
	get : get,
	set : set,
	remove : remove,
	clear : clear
