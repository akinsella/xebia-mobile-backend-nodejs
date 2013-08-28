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

angular.module('xebia-mobile-backend.auth', [])
    .config(['$httpProvider', '$routeProvider', '$locationProvider', function ($routeProvider, $locationProvider, $httpProvider) {
        $routeProvider.when('/login', { templateUrl: 'partials/login.html', controller: 'AuthCtrl' });
        $routeProvider.when('/logout', { templateUrl: 'partials/logout.html', controller: 'AuthCtrl' });

        return $httpProvider.responseInterceptors.push('errorHttpInterceptor');
    }])
    .run(function ($rootScope, $http) {
        $rootScope.user = {
            role: "ROLE_ANONYMOUS"
        };
        $http.get('/user/me').success(function (user) {
            $rootScope.user = user;
        });

        $rootScope.Auth = {
            isAuthenticated: function () {
                return this.hasNotRole("ROLE_ANONYMOUS");
            },
            isNotAuthenticated: function () {
                return !this.isAuthenticated();
            },
            hasRole: function (role) {
                return  $rootScope.user.role === role;
            },
            hasNotRole: function (role) {
                return  $rootScope.user.role !== role;
            }
        };

    });


/* Controllers */

angular.module('xebia-mobile-backend.auth', [])
    .controller('RootCtrl', [
        '$scope', '$location', 'ErrorService', function ($scope, $location, ErrorService) {
            return $scope.$on('event:loginRequired', function () {
                $location.path('/login');
            });
        }
    ])
    .controller('UserDetailsCtrl', function ($scope) {
        $scope.user = user;
        $scope.authenticated = true;
    });


/* Factories */

angular.module('xebia-mobile-backend.auth', [])
    .factory('errorHttpInterceptor', function ($q, $location, ErrorService, $rootScope) {
        return function (promise) {
            return promise.then(function (response) {
                return response;
            }, function (response) {
                if (response.status === 401) {
                    $rootScope.$broadcast('event:loginRequired');
                } else if (response.status >= 400 && response.status < 500) {
                    ErrorService.setError('Server was unable to find  what you were looking for... Sorry!!');
                }
                return $q.reject(response);
            });
        };
    })
    .factory('authHttp', function ($http, Authentication) {
        var authHttp, extendHeaders;
        authHttp = {};
        extendHeaders = function (config) {
            config.headers = config.headers || {};
            return config.headers['Authorization'] = Authentication.getTokenType() + ' ' + Authentication.getAccessToken();
        };
        angular.forEach(['get', 'delete', 'head', 'jsonp'], function (name) {
            return authHttp[name] = function (url, config) {
                config = config || {};
                extendHeaders(config);
                return $http[name](url, config);
            };
        });
        angular.forEach(['post', 'put'], function (name) {
            return authHttp[name] = function (url, data, config) {
                config = config || {};
                extendHeaders(config);
                return $http[name](url, data, config);
            };
        });
        return authHttp;
    });

