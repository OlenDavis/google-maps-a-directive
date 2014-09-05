# # a-transcluded-required-directive

# ## index.html
# 	<!DOCTYPE html>
# 	<html ng-app="aModule">
# 	
# 		<head>
# 			<link rel="stylesheet" href="style.css">
# 			<script data-require="angular.js@1.3.0-beta.19" data-semver="1.3.0-beta.19" src="https://code.angularjs.org/1.3.0-beta.19/angular.js"></script>
# 			<script src="a-transcluded-required-directive.js"></script>
# 		</head>
# 	
# 		<body class="less padded">
# 	
# 			<div
# 				class   ="bordered more padded rounded less-b-margin"
# 				ng-init ="thisMany = 1"
# 			>
# 				<div class="relative">
# 					How many? {{ thisMany }}
# 					<input
# 						type     ="range"
# 						min      ="1"
# 						max      ="20"
# 						ng-model ="thisMany"
# 						class    ="block whole-width"
# 					/>
# 				</div>
# 			</div>
# 	
# 			<div a-transcluded-required-directive="thisMany">
# 				<div
# 					class    ="less padded"
# 					ng-class ="{
# 						'blue-coloring': $even,
# 						'grey-coloring': $odd,
# 						't-rounded'    : $first,
# 						'b-rounded'    : $last
# 					}"
# 				>
# 					Transcluding at {{ $index }}
# 				</div>
# 			</div>
# 			
# 		</body>
# 	
# 	</html>

angular.module( 'aModule', [ 'ng' ] ).directive( 'aTranscludedRequiredDirective', ->

	scope:
		# This is just how many directives transcluding this required directive to render.
		thisMany: '=?aTranscludedRequiredDirective'

	# This is what makes the $transclude function available to the controller.
	transclude: yes

	# Note that we don't need the $attrs or controllerOrControllers 'cause *we're* not requiring
	# another directive
	link: ( $scope, $element ) ->
		# We $watch the thisMany value cast as a number
		$scope.$watch 'thisMany | number', ( thisMany ) ->
			$scope.soMany = new Array()

			thisMany = thisMany or 0

			# Build an array of numbers for soMany, from 1 to the value of thisMany
			$scope.soMany.push i for i in [ 1 .. thisMany ]

			debugger

	controller: ( $transclude ) ->
		$transclude: $transclude

	# Here, we just do an ng-repeat on the soMany array, and for each, use the
	# transcludeTheRequiredDirective to render the transclusion of this directive.
	template: '''
		<div>
			<div
				transclude-the-required-directive
				ng-repeat="each in soMany"
			></div>
		</div>
	'''

).directive 'transcludeTheRequiredDirective', ->
	# So, we require aTranscludedRequiredDirective (optionally) from an ancestor element.
	require: '^?aTranscludedRequiredDirective'

	link: ( $scope, $element, $attrs, aTranscludedRequiredDirectiveController ) ->
		# And then we simply call the $transclude function (which is just a $compile'd link
		# function, having compiled the content HTML/template of the aTranscludedRequiredDirective
		# instance we require'd).
		aTranscludedRequiredDirectiveController?.$transclude $scope, ( $transcludedContent ) ->
			# And then simply append that content to this directive's element.
			$element.append $transcludedContent
