mongo = require '../lib/mongo'

pureautoinc = require 'mongoose-pureautoinc'

News = new mongo.Schema(
	id: Number,
	title: {type: String, "default": '', trim: true},
	content: {type: String, "default": '', trim: true},
	type: {type: String, "enum": ['wordpress', 'twitter', 'vimeo', 'eventbrite', 'other'], trim: true },
	typeId: {type: String, "default": '', trim: true},
	imageUrl: {type: String, "default": '', trim: true},
	targetUrl: {type: String, "default": '', trim: true},
	createAt: { type: Date, "default": Date.now },
	lastModified: { type: Date, "default": Date.now },
	author: {type: String, "default": '', trim: true},
	draft: Boolean,
	publicationDate: Date,
	metadata: [{
		key: {type: String, "default": '', trim: true},
		value: {type: String, "default": '', trim: true},
	}]
)

newsModel = mongo.client.model 'News', News

News.plugin(pureautoinc.plugin, {
	model: 'News',
	field: 'id'
});

module.exports = newsModel

