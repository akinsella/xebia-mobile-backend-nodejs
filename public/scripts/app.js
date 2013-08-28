'use strict';

/* Application */

angular.module('xebia-mobile-backend', [
        'xebia-mobile-backend.auth',
        'xebia-mobile-backend.news'
    ])
    .config(['$httpProvider', '$routeProvider', '$locationProvider', function ($routeProvider, $locationProvider, $httpProvider) {
        $routeProvider.otherwise({ redirectTo: '/' });
        $locationProvider.html5Mode(true);
    }]);


/* Controllers */

angular.module('xebia-mobile-backend', [])
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
    });


/* Directives */

angular.module('xebia-mobile-backend', [])
    .directive('appVersion', ['version', function (version) {
        return function (scope, elm, attrs) {
            elm.text(version);
        };
    }]);
angular.module('xebia-mobile-backend', [])
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
    }]);


/* Factories */

angular.module('xebia-mobile-backend', [])
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
    });


/* Filters */

angular.module('xebia-mobile-backends', [])
    .filter('interpolate', ['version', function (version) {
        return function (text) {
            return String(text).replace(/\%VERSION\%/mg, version);
        }
    }]);


/* Services */

angular.module('xebia-mobile-backend', [])
    .value('version', '0.1');
