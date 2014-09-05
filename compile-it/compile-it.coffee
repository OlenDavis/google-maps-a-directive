# # Directive Basics
# ## Compile It

# ## index.html
# 	<!DOCTYPE html>
# 	<html ng-app="aModule">
# 	
# 		<head>
# 			<link rel="stylesheet" href="style.css">
# 			<script data-require="angular.js@1.3.0-beta.19" data-semver="1.3.0-beta.19" src="https://code.angularjs.org/1.3.0-beta.19/angular.js"></script>
# 			<script src="compile-it.js"></script>
# 		</head>
# 	
# 		<body class="less padded">
# 	
# 			<div class="bordered more padded rounded less-b-margin">
# 				What to compile:
# 				<textarea
# 					ng-model ="compileThis"
# 					class    ="rounded blue text-input block whole-width"
# 					rows     ="10"
# 				></textarea>
# 			</div>
# 	
# 			<div compile-it="compileThis"></div>
# 			
# 		</body>
# 	
# 	</html>


# Note here we inject $compile as a dependency for the directive itself. We could also have our
# logic in a controller (for portability's sake primarily), and inject $compile into the controller.
angular.module( 'aModule', [ 'ng' ] ).directive( 'compileIt', ( $compile ) ->
	scope:
		# This is the interpolated scope attribute we'll attempt to $compile and display.
		compileWhat: '=?compileIt'

	# Note that we don't need the $attrs or controllerOrControllers
	link: ( $scope, $element ) ->
		# So, we watch the compileIt string:
		$scope.$watch 'compileWhat', ( compileWhat ) ->
			try
				# And when it changes, we'll try to compile the thing to get its compiled link
				# function and put it on the scope:
				$scope.compiledLinkFunction = $compile compileWhat
			catch e
				# And if compilation fails, we'll unset that function on the scope
				$scope.compiledLinkFunction = null

		$scope.$watchGroup [ 'compiledLinkFunction', 'compileWhat' ], ( args ) ->
			[ compiledLinkFunction, compileWhat ] = args

			unless compiledLinkFunction? and compileWhat?
				$scope.whatCompiled = null
			else
				try
					$scope.compiledLinkFunction $scope, ( whatCompiled ) ->
						$scope.whatCompiled = whatCompiled
				catch e
					$scope.whatCompiled = null


		$scope.compileIt = ->
			return unless $scope.compiledLinkFunction

	# Here, we want to both display the un-compiled template string as HTML, and if it was able to
	# be compiled, give the user a button to compile the template and show them the havok they've
	# just wrot.
	template: '''
		<div class="bordered rounded more padded">
			
			<div ng-if="compileWhat && ! compiledLinkFunction">
				Can't compile it:
				<div class="bordered rounded less padded b-margin">
					{{ compileWhat }}
				</div>
			</div>
			
			<div ng-if="whatCompiled">
				What compiled:
				<div class="bordered rounded less padded t-margin">
					<div replace-with="whatCompiled"></div>
				</div>
			</div>

		</div>
	'''
).directive 'replaceWith', ->
	# *Extra:* This is just a little directive to put an element onto the page without resorting to
	# too much jQLite hackery.
	scope: replaceWith: '=?'

	link: ( $scope, $element ) ->
		$scope.$watch 'replaceWith', ( replaceWith ) ->
			$element.html ''
			if replaceWith?
				$element.append replaceWith 