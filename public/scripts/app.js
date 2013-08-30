
'use strict';

/* Application */

angular.module('xebia-mobile-backend', [])


    /* Config */

    .config(['$routeProvider', '$locationProvider', '$httpProvider', function ($routeProvider, $locationProvider, $httpProvider) {
        $routeProvider
            .when('/', { templateUrl: 'partials/index.html', controller: 'RootCtrl' })
            .when('/login', { templateUrl: 'partials/login.html', controller: 'AuthCtrl' })
            .when('/account', { templateUrl: 'partials/account.html', controller: 'AuthCtrl' })
            .when('/news', { templateUrl: 'partials/news/list.html', controller: 'NewsCtrl' })
            .when('/news/create', { templateUrl: 'partials/news/crate.html', controller: 'NewsCtrl' })
            .when('/news/update', { templateUrl: 'partials/news/update.html', controller: 'NewsCtrl' })
            .otherwise({ redirectTo: '/' });
        return $httpProvider.responseInterceptors.push('errorHttpInterceptor');
    }])
    .run(['$rootScope', '$http', '$location', function ($rootScope, $http, $location) {
        $rootScope.$on('event:loginRequired', function () {
            $location.path('/login');
        });
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
    }])

    /* Controllers */

    .controller('RootCtrl', [
        '$scope', '$location', 'ErrorService', function ($scope, $location, ErrorService) {
            $scope.errorService = ErrorService;
        }
    ])
    .controller('SubMenuCtrl', function ($scope) {
        $scope.menus = [
            {
                message: 'Item 1',
                url: "item/1"
            },
            {
                message: 'Item 2',
                url: "item/2"
            },
            {
                message: 'Item 3',
                url: "item/3"
            }
        ];
    })
    .controller('SidebarCtrl', function ($scope) {

    })
    .controller('ContentCtrl', function ($scope) {
        $scope.sidebar = true;
    })
    .controller('IndexCtrl', function ($scope) {
        $scope.title = "Home";
        $scope.user = user;
        $scope.authenticated = false;
    })


    /* Directives */

    .directive('appVersion', ['version', function (version) {
        return function (scope, elm, attrs) {
            elm.text(version);
        };
    }])
    .directive('alertBar', ['$parse', function ($parse) {
        return {
            restrict: 'A',
            template: '<div class="alert alert-error alert-bar" ng-show="errorMessage">\n	<button type="button" class="close" ng-click="hideAlert()">x</button>\n	{{errorMessage}}\n</div>',
            link: function (scope, elem, attrs) {
                var alertMessageAttr;
                alertMessageAttr = attrs['alertmessage'];
                scope.errorMessage = null;
                scope.$watch(alertMessageAttr, function (newVal) {
                    return scope.errorMessage = newVal;
                });
                return scope.hideAlert = function () {
                    scope.errorMessage = null;
                    return $parse(alertMessageAttr).assign(scope, null);
                };
            }
        };
    }])


    /* Factories */

    .factory('ErrorService', function () {
        return {
            errorMessage: null,
            setError: function (msg) {
                this.errorMessage = msg;
            },
            clear: function () {
                this.errorMessage = null;
            }
        };
    })


    /* Filters */

    .filter('interpolate', ['version', function (version) {
        return function (text) {
            return String(text).replace(/\%VERSION\%/mg, version);
        }
    }])


    /* Services */

    .value('version', '0.1');
