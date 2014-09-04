# # Directive Basics
# ## A Required Directive
angular.module( 'aModule', [ 'ng' ] ).directive( 'aDirective', ->
	# Note the isolate scope:
	scope: {}

	# Here, we *require* (optionally) the aRequiredDirective to be a parent of this directive:
	require: '^?aRequiredDirective'

	# Note that aRequiredDirective's controller is passed to the 4th parameter here:
	link: ( $scope, $element, $attrs, controllerOrControllers ) ->
		# So, we just put it on the scope for later use in the directive template.
		$scope.aRequiredDirectiveController = controllerOrControllers

	# Here, note that `aRequiredDirectiveController.getResult()` evaluates to something. And for
	# purely demonstrative purposes, `something` and `somethingAdded` are undefined (because this
	# directive has an isolate scope). This is reinforce the fact that we're displaying what we're
	# displaying thanks to require, not just scope inheritance.
	template: '''
		<div class="bordered rounded more padded">
			aRequiredDirective's getResult(): {{ aRequiredDirectiveController.getResult() }}
			<br/>
			something: {{ something }}
			<br/>
			somethingAdded: {{ somethingAdded }}
		</div>
	'''
).directive( 'aRequiredDirective', ->
	scope:
		something     : '=?'
		somethingAdded: '=?'

	controller: ( $scope ) ->
		getResult: ->
			"#{ $scope.something }|#{ $scope.somethingAdded }"
)