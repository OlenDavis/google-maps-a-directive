# # alert-this-and-that

# ## index.html
# 	<!DOCTYPE html>
# 	<html ng-app="aModule">
# 	
# 		<head>
# 			<link rel="stylesheet" href="style.css">
# 			<script data-require="angular.js@1.3.0-beta.19" data-semver="1.3.0-beta.19" src="https://code.angularjs.org/1.3.0-beta.19/angular.js"></script>
# 			<script src="alert-this-and-that.js"></script>
# 		</head>
# 	
# 		<body class="less padded">
# 			<div
# 				class               ="bordered more padded rounded less-b-margin"
# 				ng-init             ="statements = [ 'sure you do.', 'omg', 'yep', 'whaaaaaaat.', 'yee, hah.', 'er, mah, ger.' ]"
# 				alert-this-and-that ="statement.toUpperCase() and statement.toLowerCase() for statement in statements"
# 			>
# 				I do what I WANT... {{ statement }}
# 			</div>
# 		</body>
# 	
# 	</html>


# ### The Regular Expressions

# Our expression will be of the form `_alert_this_ and _alert_that for _ng_repeat_expression_`. So,
# we just want a simple regular expression that matches groups for those three parts like so:
alertThisAndThatRegex = /^\s*([\s\S]+?)\s+and\s+([\s\S]+?)\s+for\s+([\s\S]+?)\s*$/

# #### Demystifying ngRepeat
# *FYI* The processing of ngRepeat's expression is just applying several regular expressions in phases.

# For instance, this is the regex for splitting the ngRepeat expression into its left and right sides. I.e. `ng-
# repeat="_left_side in _right_side_"`

# 	ngRepeatRegex = /^\s*([\s\S]+?)\s+in\s+([\s\S]+?)\s*$/

# This is the regex for extracting the various value pieces from the ngRepeat's left side. I.e.
# `_left_side` is `_value_|(_key_, _value_)`

# 	ngRepeatLhsRegex = /^(?:([\$\w]+)|\(([\$\w]+)\s*,\s*([\$\w]+)\))$/

# We need $compile to build our ngRepeat template with the ngRepeat expression extracted from the directive attribute. (We also get $log to log errors appropriately.)
angular.module( 'aModule', [ 'ng' ] ).directive( 'alertThisAndThat', ( $compile, $log )->

	# To prove we're not cheating, an isolate scope.
	scope: {}

	transclude: yes

	link: ( $scope, $element, $attrs ) ->

	# We need $attrs to process our expression, and we need $transclude to pass to the child directive that's going to use it from within its ngRepeat.
	controller: ( $scope, $attrs, $transclude ) ->
		expression = $attrs.alertThisAndThat
		return $log.warn "No expression for alertThisAndThat" unless expression?.length

		# Parse the overall expression:
		matches = expression.match alertThisAndThatRegex

		# And blow up if it didn't match:
		return $log.error "alertThisAndThat expression was malformed: #{ expression }" unless matches

		# Extract each sub-expression of it:
		thisExpression     = matches[ 1 ]
		thatExpression     = matches[ 2 ]
		ngRepeatExpression = matches[ 3 ]

		# And blow up if any of them weren't there:
		return $log.error "alertThisAndThat expression missing the this expression: #{     expression }" unless thisExpression?.length
		return $log.error "alertThisAndThat expression missing the that expression: #{     expression }" unless thatExpression?.length
		return $log.error "alertThisAndThat expression missing the ngRepeat expression: #{ expression }" unless ngRepeatExpression?.length

		# Then build the controller object and return it:
		controller =
			$scope            : $scope
			$transclude       : $transclude
			thisExpression    : matches[ 1 ]
			thatExpression    : matches[ 2 ]
			ngRepeatExpression: matches[ 3 ]

	template: '''
		<div class="no-wrap">

			<div class="inline-block wrap more r-padded">
				<div this-alerts></div>
			</div>

			<div class="inline-block wrap">
				<div that-alerts></div>
			</div>

		</div>
	'''
).directive( 'thisAlerts', ( $compile ) ->
	# So, we require alertThisAndThat from an ancestor element.
	require: '^alertThisAndThat'

	# An isolate scope to ensure transclusion's $scope will be unpolluted.
	scope: {}

	link: ( $scope, $element, $attrs, alertThisAndThatController ) ->
		# Now we build ngRepeat template and compile it.

		# The key here is to make this template absolutely as simple as possible.

		# *Future Note*: There's a very good reason for separating the alert-this from the
		# ngRepeat...to ensure we can get a clean/isolated scope for the transclusion that only has
		# what the ngRepeat puts on it for the transcluded template.
		compiledNgRepeat = $compile "
		<div ng-repeat='#{ alertThisAndThatController.ngRepeatExpression }'>
			<div alert-this></div>
		</div>
		"

		# **Magic Alert!¡** Then we link it to *the parent scope of the alertThisAndThat directive*.
		compiledNgRepeat alertThisAndThatController.$scope.$parent, ( $linkedNgRepeatElement ) ->
			# And append it.
			$element.append $linkedNgRepeatElement

).directive( 'thatAlerts', ( $compile ) ->
	# So, we require alertThisAndThat from an ancestor element.
	require: '^alertThisAndThat'

	# An isolate scope to ensure transclusion's $scope will be unpolluted.
	scope: {}

	link: ( $scope, $element, $attrs, alertThisAndThatController ) ->
		# Now we build ngRepeat template and compile it.

		# The key here is to make this template absolutely as simple as possible.

		# *Future Note*: There's a very good reason for separating the alert-that from the
		# ngRepeat...to ensure we can get a clean/isolated scope for the transclusion that only has
		# what the ngRepeat puts on it for the transcluded template.
		compiledNgRepeat = $compile "
		<div ng-repeat='#{ alertThisAndThatController.ngRepeatExpression }'>
			<div alert-that></div>
		</div>
		"

		# **Magic Alert!¡** Then we link it to *the parent scope of the alertThisAndThat directive*.
		compiledNgRepeat alertThisAndThatController.$scope.$parent, ( $linkedNgRepeatElement ) ->
			# And append it.
			$element.append $linkedNgRepeatElement

).directive( 'alertThis', ( $compile ) ->
	# So, we require alertThisAndThat from an ancestor element.
	require: '^alertThisAndThat'

	# Just to absolutely ensure we don't accidentally clobber anything in the ng-repeat's scope
	# (which we want to preserve, totally unpolluted for the transclusion of the alertThisAndThat
	# directive), we give this an isolate scope.
	scope: {}

	link: ( $scope, $element, $attrs, alertThisAndThatController ) ->
		# We declare the value that will be alerted when the button is clicked.
		thisValue = null

		# And we watch the _this_expression_ extracted and saved on the require'd alertThisAndThat's
		# controller to update what we'll alert whenever it changes.
		$scope.$watch alertThisAndThatController.thisExpression, ( value ) ->
			thisValue = value

		# Almost done, we define the alert function. And note that because this directive is
		# declared on/under an ngRepeat, all its scopes are "siblings" or in other words don't
		# clobber one another.
		$scope.alert = -> alert thisValue

		# Finally, we transclude the alertThisAndThat directive's contents *using this scope's
		# parent scope*, just to prove we can, and can do so with a completely unpolluted
		# transcluded scope that still has access to all the wonderful stuff ngRepeat puts on there:
		debugger
		alertThisAndThatController.$transclude $scope.$parent, ( $transcludedAlertThis ) ->
			$element.append $transcludedAlertThis

	template: '''
	<div>
		<button
			class    ="link appearance-none not-bordered rounded blue coloring red-flat-button"
			ng-click ="alert()"
		>
			Alert This
		</button>
	</div>
	'''
).directive( 'alertThat', ( $compile ) ->
	# So, we require alertThisAndThat from an ancestor element.
	require: '^alertThisAndThat'

	# Just to absolutely ensure we don't accidentally clobber anything in the ng-repeat's scope
	#	 (which we want to preserve, totally unpolluted for the transclusion of the alertThisAndThat
	#	 directive), we give this an isolate scope.
	scope: {}

	link: ( $scope, $element, $attrs, alertThisAndThatController ) ->
		# We declare the value that will be alerted when the button is clicked.
		thatValue = null

		# And we watch the _that_expression_ extracted and saved on the require'd alertThisAndThat's
		# controller to update what we'll alert whenever it changes.
		$scope.$watch alertThisAndThatController.thatExpression, ( value ) ->
			thatValue = value

		# Almost done, we define the alert function. And note that because this directive is
		# declared on/under an ngRepeat, all its scopes are "siblings" or in other words don't
		# clobber one another.
		$scope.alert = -> alert thatValue

		# Finally, we transclude the alertThisAndThat directive's contents *using this scope's
		# parent scope*, just to prove we can, and can do so with a completely unpolluted
		# transcluded scope that still has access to all the wonderful stuff ngRepeat puts on there:
		debugger
		alertThisAndThatController.$transclude $scope.$parent, ( $transcludedAlertThat ) ->
			$element.append $transcludedAlertThat

	template: '''
	<div>
		<button
			class    ="link appearance-none not-bordered rounded blue coloring red-flat-button"
			ng-click ="alert()"
		>
			Alert That
		</button>
	</div>
	'''
)