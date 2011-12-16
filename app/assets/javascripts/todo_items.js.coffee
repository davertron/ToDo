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
					todo_item:
						_id: @_id
						content: @content
						complete: @complete()
						priority: @priority
				type: 'PUT'
				dataType: 'html'
				url: "/todo_items/#{@_id}.json"
			.fail (a, b, c) =>
				console.log 'Oh noes, unable to save or problem with response: ', a, b, c
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
