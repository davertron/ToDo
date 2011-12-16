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

			@needsUpdate = ko.dependentObservable ->
				this.complete()

				this.updating(true)
				defer = new $.Deferred()
				showSpinnerForAtLeastHalfASecond = ->
					setTimeout ->
						defer.resolve()
					, 500
					return defer.promise()

				$.when($.ajax(
					data:
						todo_item:
							_id: this._id
							content: this.content
							complete: this.complete()
							priority: this.priority
					type: 'PUT'
					dataType: 'html'
					url: "/todo_items/#{this._id}.json"
				), showSpinnerForAtLeastHalfASecond())
				.done =>
					this.updating(false)
				.fail (a, b, c) ->
					console.log 'Oh noes, unable to save or problem with response: ', a, b, c
			, this


	viewModel =
		todos: ko.observableArray()

	for todo in TODO.todos
		viewModel.todos.push new Todo todo

	$('.todo-item').remove()

	ko.applyBindings viewModel

	$('#save').click ->
		for todo in viewModel.todos()
			todo.update()
