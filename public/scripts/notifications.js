(function() {

    'use strict';

    /* Application */
    angular.module('xebia-mobile-backend')

        /* Factories */
        .factory('NotificationData', ["baseApiUrl", '$http', function(baseApiUrl, $http) {
            return {
                notifications : function() {
                    return $http({
                        method: 'JSONP',
                        url: baseApiUrl + '/api/v1/notifications?callback=JSON_CALLBACK'
                    });
                }
            }
        }])

        .factory('DeviceData', ['baseApiUrl', '$http', function(baseApiUrl, $http) {
            return {
                devices : function() {
                    return $http({
                        method: 'JSONP',
                        url: baseApiUrl + '/api/v1/devices?callback=JSON_CALLBACK'
                    });
                }
            }
        }])


        /* Controllers */
        .controller('NotificationsCtrl', ['$scope', 'NotificationData', function ($scope, NotificationData) {
            console.log("Notifications Controller");
                NotificationData.notifications().then(function(response) {
                    $scope.notifications = response.data;
                    console.log("Notifications", response.data);
                });
            }
        ])

        .controller('DevicesCtrl', ['$scope', 'DeviceData', function ($scope, DeviceData) {
                console.log("Devices Controller");
                DeviceData.devices().then(function(response) {
                    $scope.devices = response.data;
                    console.log("Devices", response.data);
                });
            }
        ]);

})();
