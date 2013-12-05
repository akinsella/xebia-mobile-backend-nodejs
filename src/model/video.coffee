mongo = require '../lib/mongo'

Video = new mongo.Schema(
	id: {type: String, "default": '', trim: true},
	privacy: {type: String, "default": '', trim: true},
	title: {type: String, "default": '', trim: true},
	owner: {
		id: {type: String, "default": '', trim: true},
		username: {type: String, "default": '', trim: true},
		profileUrl: {type: String, "default": '', trim: true},
		displayName: {type: String, "default": '', trim: true},
		isPlus: Boolean,
		isPro: Boolean,
		isStaff: Boolean,
		realName: {type: String, "default": '', trim: true},
		videosUrl: {type: String, "default": '', trim: true}
	},
	is_watcher: Number,
	thumbnails: [{
		width: Number,
		height: Number,
		url: {type: String, "default": '', trim: true}
	}]
	embedPrivacy: {type: String, "default": '', trim: true},
	isHd: Boolean,
	isTranscoding: Boolean,
	uploadDate: {type: String, "default": '', trim: true},
	modifiedDate: {type: String, "default": '', trim: true},
	likeCount: Number,
	commentCount: Number,
	playCount: Number
)

videoModel = mongo.client.model 'Video', Video

module.exports = videoModel

