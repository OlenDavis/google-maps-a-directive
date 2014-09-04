# # Directive Basics
# ## A Transcluded Required Directive
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
