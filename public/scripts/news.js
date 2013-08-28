'use strict';
var user;

user = {
    firstName: "Alexis",
    lastName: "Kinsella",
    avatarUrl: "images/avatar_placeholder.png",
    fullName: "Alexis Kinsella",
    email: "alexis.kinsella@gmail.com"
};


/* Application */

angular.module('xebia-mobile-backend.news', [
        'xebia-mobile-backend.factories',
        'xebia-mobile-backend.directives',
        'xebia-mobile-backend.controllers',
        'xebia-mobile-backend.filters',
        'xebia-mobile-backend.services'
    ])
    .config(['$httpProvider', '$routeProvider', '$locationProvider', function ($routeProvider, $locationProvider, $httpProvider) {
        $routeProvider.when('/news', { templateUrl: 'partials/news/list.html', controller: 'NewsCtrl' });
        $routeProvider.when('/news/create', { templateUrl: 'partials/news/crate.html', controller: 'NewsCtrl' });
        $routeProvider.when('/news/update', { templateUrl: 'partials/news/update.html', controller: 'NewsCtrl' });
    }]);


/* Controllers */

angular.module('xebia-mobile-backend.news', [])
    .controller('NewsCtrl', [
        '$scope', '$location', 'ErrorService', function ($scope, $location, ErrorService) {
        }
    ]);

