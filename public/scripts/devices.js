(function() {

    'use strict';

    /* Application */
    angular.module('xebia-mobile-backend')

        /* Factories */
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
        .controller('DevicesCtrl', ['$scope', 'DeviceData', function ($scope, DeviceData) {
                console.log("Devices Controller");
                DeviceData.devices().then(function(response) {
                    $scope.devices = response.data;
                    console.log("Devices", response.data);
                });
            }
        ]);

})();
