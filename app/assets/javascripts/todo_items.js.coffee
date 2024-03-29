# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
	logError = (a, b, c) ->
		console.log 'Oh noes, unable to save or problem with response: ', a, b, c

	class Todo
		constructor: (mongoTodo) ->
			@_id = mongoTodo._id
			@content = mongoTodo.content
			@complete = ko.observable mongoTodo.complete
			@priority = mongoTodo.priority
			@updating = ko.observable false
			@completed_on = ko.observable(new Date(Date.parse mongoTodo.completed_on))

			# When the completion status changes, update over ajax
			@complete.subscribe =>
				@updating true
				defer = new $.Deferred()
				showSpinnerForAtLeastHalfASecond = ->
					setTimeout ->
						defer.resolve()
					, 500
					return defer.promise()

				if @complete()
					@completed_on new Date()
				else
					@completed_on '2000-01-01'

				$.when($.ajax(
					data:
						todo_item:
							_id: @_id
							content: @content
							complete: @complete()
							completed_on: if isNaN(@completed_on()) then '2000-01-01' else @completed_on().getFullYear() + '-' + (@completed_on().getMonth() + 1) + '-' + @completed_on().getDate()
							priority: @priority
					type: 'PUT'
					dataType: 'html'
					url: "/todo_items/#{@_id}.json"
				), showSpinnerForAtLeastHalfASecond())
				.done =>
					@updating false
				.fail logError


	viewModel =
		sendableTodo: ko.observable false
		handleNewTodoKeyPress: ->
			this.sendableTodo $('#new-todo-content').val().length > 0
			return true
		todos: ko.observableArray()

	# TODO: Namespace my shiz
	if window.TODO and window.TODO.todos
		for todo in window.TODO.todos
			viewModel.todos.unshift new Todo todo

		$('.todo-item').remove()

		# Clear any alerts (such as login success, etc.) after 5 seconds
		setTimeout ->
			$('.alert-message').fadeOut()
		, 5000

		ko.applyBindings viewModel

		# Remove static link to new todo page and replace with a form input for
		# adding todos dynamically
		$('#new-todo-link').hide()
		$('#new-todo-form').show().submit (e) ->
			e.preventDefault()
			content = $('#new-todo-content').val()
			if content.length > 0
				$.ajax
					data:
						todo_item:
							content: content
							complete: false
							priority: 1
					type: 'POST'
					url: '/todo_items.json'
					success: (response) ->
						$('#new-todo-content').val ''
						viewModel.todos.unshift new Todo response
						viewModel.sendableTodo false
					error: logError

		# Wire up delete links
		$('.delete-todo').live 'click', (e) ->
			e.preventDefault()
			$link = $(this)
			$.ajax
				type: 'DELETE'
				url: $link.attr 'href'
				dataType: 'html'
				success: (response) ->
					viewModel.todos.remove (todo) ->
						return todo._id == $link.closest('tr').attr 'id'
				error: logError
