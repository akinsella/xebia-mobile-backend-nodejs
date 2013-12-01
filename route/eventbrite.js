// Generated by CoffeeScript 1.6.3
var Event, apiKey, config, event, eventProps, fs, list, organizerProps, processRequest, utils, venueProps, _;

utils = require('../lib/utils');

_ = require('underscore')._;

fs = require('fs');

config = require('../conf/config');

Event = require('../model/event');

apiKey = process.env["EVENTBRITE_AUTH_KEY"];

processRequest = function(req, res, url, transform) {
  var options;
  options = utils.buildOptions(req, res, url, 5 * 60, transform);
  return utils.processRequest(options);
};

eventProps = ["id", "category", "capacity", "title", "start_date", "end_date", "timezone_offset", "tags", "created", "url", "privacy", "status", "description", "description_plain_text", "organizer", "venue"];

organizerProps = ["id", "name", "url", "description"];

venueProps = ["id", "name", "city", "region", "country", "country_code", "address", "address_2", "postal_code", "longitude", "latitude"];

list = function(req, res) {
  if (config.offlineMode) {
    res.charset = 'UTF-8';
    return res.send(JSON.parse(fs.readFileSync("" + __dirname + "/../data/eventbrite_event.json", "utf-8")));
  } else {
    return Event.find({}).sort("-start_date").limit(50).exec(function(err, events) {
      if (err) {
        return res.json(500, {
          message: "Server error: " + err.message
        });
      } else if (!event) {
        return res.json(404, "Not Found");
      } else {
        events = events.map(function(event) {
          event = event.toObject();
          delete event._id;
          delete event.__v;
          return event;
        });
        return res.json(events);
      }
    });
  }
};

event = function(req, res) {
  var eventId;
  eventId = req.params.id;
  return Event.findOne({
    id: eventId
  }, function(err, event) {
    if (err) {
      return res.json(500, {
        message: "Server error: " + err.message
      });
    } else if (!event) {
      return res.json(404, "Not Found");
    } else {
      event = event.toObject();
      delete event._id;
      delete event.__v;
      return res.json(event);
    }
  });
};

module.exports = {
  list: list,
  event: event
};

/*
//@ sourceMappingURL=eventbrite.map
*/
