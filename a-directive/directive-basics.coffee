# # Directive Basics

# ## index.html
# 	<!DOCTYPE html>
# 	<html ng-app="aModule">
# 	
# 		<head>
# 			<script data-require="angular.js@1.3.0-beta.19" data-semver="1.3.0-beta.19" src="https://code.angularjs.org/1.3.0-beta.19/angular.js"></script>
# 			<script src="directive-basics.js"></script>
# 		</head>
# 	
# 		<body>
# 			<div
# 				a-directive
# 				two-way-bound="toThis"
# 			></div>
# 		</body>
# 	
# 	</html>

# How a directive is made:
angular.module( 'aModule', [ 'ng' ] ).directive 'aDirective', ->
	# ## The "Directive Definition Object"

	# It's what makes a directive a directive. It's also basically a cross between Walmart clothes
	# and swing-state politicians: one size fits all, and painful to look at.
	scope:
		# Here are your scope attributes:
		twoWayBound        : '='
		optionalTwoWayBound: '=?'
		interpolated       : '@'
		anExpression       : '&'

		# An aliased scope attribute:
		thisModule: '@aDirective'

	# ## The Directive's $scope
	# ### 2 Ways:
	# Via the "link function":
	link: ( $scope, $element, $attrs, controllerOrControllers ) ->
		# This is *place #1* where you'll typically put the script that constitutes your directive.
		$scope.something = 'stuff'

		$scope.alertSomething = ->
			alert $scope.something

		$scope.$watch 'something + somethingElse', ( everything ) ->
			$scope.everything = everything

	# Or via the directive's controller as an injected dependency:
	controller: ( $scope ) ->
		# This is *place #2* where you'll typically put the script that constitutes your directive.
		$scope.somethingElse = 'other stuff'

		$scope.alertSomethingElse = ->
			alert $scope.somethingElse

		$scope.$watch 'everything', ( everything, lastEverything ) ->
			return if everything is lastEverything

			$scope.everythingChangedBy = ( everything?.length or 0 ) - ( lastEverything?.length or 0 )

	# And here's where you CAN (though I don't personally recommend it) place the template for the
	# directive (if template it uses).
	template: '''
		<div>

			<div>

				<input ng-model="something"/>

				<button ng-click="alertSomething()">Alert Something</button>

			</div>

			<div>

				<input ng-model="somethingElse"/>

				<button ng-click="alertSomethingElse()">Alert Something Else</button>

			</div>

			And everything changed by {{ everythingChangedBy }}

		</div>
	'''