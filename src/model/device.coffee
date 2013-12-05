mongo = require '../lib/mongo'
pureautoinc  = require('mongoose-pureautoinc');

Device = new mongo.Schema(
  id: Number,
  udid: {type : String, "default" : '', trim : true},
  token: {type : String, "default" : '', trim : true},
  osType: {type : String, "default" : '', trim : true},
  osVersion: {type : String, "default" : '', trim : true},
  createAt: { type : Date, "default" : Date.now },
  lastModified: { type : Date, "default" : Date.now }
)

deviceModel = mongo.client.model 'Device', Device

Device.plugin(pureautoinc.plugin, {
    model: 'Device',
    field: 'id'
});

module.exports = deviceModel

