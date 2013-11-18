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


        /* Controllers */
        .controller('NotificationsCtrl', ['$scope', '$location', 'NotificationData', function ($scope, $location, NotificationData) {
            console.log("Notifications Controller");
            NotificationData.notifications().then(function(response) {
                $scope.notifications = response.data;
                console.log("Notifications", response.data);
            });

            $scope.createNotification = function() {
                $location.path("#/notification/createNotification.html");
            }
        }]);
})();
