'use strict';

# User

user =
	firstName: "Alexis"
	lastName: "Kinsella"
	avatarUrl: "images/avatar_placeholder.png"
	fullName: "Alexis Kinsella"
	email: "alexis.kinsella@gmail.com"


### Application Module ###

appModule = angular.module 'xebia-notification', []




### Services ###

appModule.factory 'ErrorService', () ->
	errorMessage: null

	setError: (msg) ->
		this.errorMessage = msg
		return

	clear: () ->
		this.errorMessage = null
		return

appModule.config ($httpProvider) ->
	$httpProvider.responseInterceptors.push 'errorHttpInterceptor'


# register the interceptor as a service
# intercepts ALL angular ajax HTTP calls

appModule.factory 'errorHttpInterceptor', ($q, $location, ErrorService, $rootScope) ->
	(promise) ->
		promise.then(
			(response) ->
				response
			,
			(response) ->
				if response.status == 401
					$rootScope.$broadcast('event:loginRequired');
				else if response.status >= 400 && response.status < 500
					ErrorService.setError 'Server was unable to find  what you were looking for... Sorry!!'

				$q.reject(response)
		)


# This factory is only evaluated once, and authHttp is memorized. That is,
# future requests to authHttp service return the same instance of authHttp

appModule.factory 'authHttp', ($http, Authentication) ->
	authHttp = {}

	# Append the right header to the request
	extendHeaders = (config) ->
		config.headers = config.headers || {};
		config.headers['Authorization'] = Authentication.getTokenType() + ' ' + Authentication.getAccessToken()

	# Do this for each $http call
	angular.forEach ['get', 'delete', 'head', 'jsonp'], (name) ->
		authHttp[name] = (url, config) ->
			config = config || {}
			extendHeaders(config)
			$http[name](url, config)

	angular.forEach ['post', 'put'], (name) ->
		authHttp[name] = (url, data, config) ->
			config = config || {}; extendHeaders(config)
			$http[name](url, data, config)

	authHttp



### Controllers ###

appModule.controller 'RootController', ['$scope', '$location', 'ErrorService', ($scope, $location, ErrorService) ->
	$scope.errorService = ErrorService
	$scope.$on 'event:loginRequired', () ->
		$location.path '/login'
		return
]

appModule.controller 'UserDetailsController', ($scope) ->
	$scope.user = user
	$scope.authenticated = true
	return

appModule.controller 'SubMenuController', ($scope) ->
	$scope.menus = [
		{ message: 'Item 1', url: "item/1"},
		{ message: 'Item 2', url: "item/2"},
		{ message: 'Item 3', url: "item/3"}
	]
	return

appModule.controller 'SidebarController', ($scope) ->
	return

appModule.controller 'ContentController', ($scope) ->
	$scope.sidebar = true
	return

appModule.controller 'IndexController', ($scope) ->
	$scope.title = "Home"
	$scope.user = user
	$scope.authenticated = false
	return

### Directives ###

appModule.directive 'alertBar', ['$parse', ($parse) ->
	restrict: 'A',
	template: '''
		<div class="alert alert-error alert-bar" ng-show="errorMessage">
			<button type="button" class="close" ng-click="hideAlert()">x</button>
			{{errorMessage}}
		</div>
	'''

	link: (scope, elem, attrs) ->
		alertMessageAttr = attrs['alertmessage']
		scope.errorMessage = null

		scope.$watch alertMessageAttr, (newVal) ->
			scope.errorMessage = newVal;


		scope.hideAlert = () ->
			scope.errorMessage = null
			# Also clear the error message on the bound variable.
			# Do this so that if the same error happens again
			# the alert bar will be shown again next time.
			$parse(alertMessageAttr).assign(scope, null)
]