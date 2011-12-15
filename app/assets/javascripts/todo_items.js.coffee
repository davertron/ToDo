# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
	class Todo
		constructor: (mongoTodo) ->
			@_id = mongoTodo._id
			@content = mongoTodo.content
			@complete = ko.observable mongoTodo.complete
			@priority = mongoTodo.priority
			@updating = ko.observable false

		update: ->
			@updating(true)
			$.ajax
				data:
					_method: 'put'
					todo_item:
						_id: @_id
						content: @content
						complete: @complete()
						priority: @priority
				type: 'POST'
				url: "/todo_items/#{@_id}.json"
			.success =>
				console.log 'Yay!'
			.fail (a, b, c) =>
				console.log 'Oh noes', a, b, c
			.complete =>
				@updating(false)

	viewModel =
		todos: ko.observableArray()

	for todo in TODO.todos
		viewModel.todos.push new Todo todo

	$('.todo-item').remove()

	ko.applyBindings viewModel

	$('#save').click ->
		for todo in viewModel.todos()
			todo.update()
