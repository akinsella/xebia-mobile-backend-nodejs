// Generated by CoffeeScript 1.6.3
var eventProps, list, organizerProps, processRequest, utils, venueProps, _,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

utils = require('../lib/utils');

_ = require('underscore')._;

processRequest = function(req, res, url, transform) {
  var options;
  options = utils.buildOptions(req, res, url, 5 * 60, transform);
  utils.processRequest(options);
};

eventProps = ["id", "category", "capacity", "title", "start_date", "end_date", "timezone_offset", "tags", "created", "url", "privacy", "status", "description", "description_plain_text", "organizer", "venue"];

organizerProps = ["id", "name", "url", "description"];

venueProps = ["id", "name", "city", "region", "country", "country_code", "address", "address_2", "postal_code", "longitude", "latitude"];

list = function(req, res) {
  var apiKey;
  apiKey = process.env.EVENTBRITE_AUTH_KEY;
  return processRequest(req, res, "https://www.eventbrite.com/json/organizer_list_events?app_key=" + apiKey + "&id=1627902102", function(data) {
    data = _(data.events).pluck("event").filter(function(event) {
      return event.status === "Live";
    });
    _(data).each(function(event) {
      var key, oKey, vKey;
      for (key in event) {
        if (!(__indexOf.call(eventProps, key) >= 0)) {
          delete event[key];
        }
        for (vKey in event.venue) {
          if (!(__indexOf.call(venueProps, vKey) >= 0)) {
            delete event.venue[vKey];
          }
        }
        for (oKey in event.organizer) {
          if (!(__indexOf.call(organizerProps, oKey) >= 0)) {
            delete event.organizer[oKey];
          }
        }
      }
      return event;
    });
    return data;
  });
};

module.exports = {
  list: list
};
