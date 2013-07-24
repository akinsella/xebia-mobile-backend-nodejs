// Generated by CoffeeScript 1.6.3
var Device, apn, create, findById, list, removeById, utils, _;

utils = require('../lib/utils');

_ = require('underscore')._;

apn = require('apn');

Device = require("../model/device");

create = function(req, res) {
  var device;
  device = new Device({
    udid: req.body.udid,
    token: req.body.token
  });
  return device.save(function(err) {
    if (err) {
      utils.responseData(500, "Could not save device", req.body, {
        req: req,
        res: res
      });
    } else {
      utils.responseData(201, "Created", device, {
        req: req,
        res: res
      });
    }
  });
};

list = function(req, res) {
  return Device.find({}, function(err, devices) {
    utils.responseData(200, void 0, devices, {
      req: req,
      res: res
    });
  });
};

findById = function(req, res) {
  return Device.findOne({
    id: req.params.id
  }, function(err, device) {
    if (device) {
      utils.responseData(200, void 0, device, {
        req: req,
        res: res
      });
    } else {
      utils.responseData(404, "Not Found", void 0, {
        req: req,
        res: res
      });
    }
  });
};

removeById = function(req, res) {
  return Device.findOneAndRemove({
    id: req.params.id
  }, function(err, device) {
    if (device) {
      utils.responseData(204, void 0, device, {
        req: req,
        res: res
      });
    } else {
      utils.responseData(404, "Not Found", void 0, {
        req: req,
        res: res
      });
    }
  });
};

module.exports = {
  create: create,
  list: list,
  findById: findById,
  create: create,
  removeById: removeById
};

/*
//@ sourceMappingURL=device.map
*/
