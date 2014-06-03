class SnakeGame
	constructor: (container, opts={}) ->
		@container = $ container
		@set_opts opts
		@snake = @create_snake()
		@rendered = false
		@ticks = 0
		@game_speeds = [5, 3]
		@set_game_speed @opts.game_speed
		@paused = false

		@setup_events()
		@update()
		
	set_opts: (opts={}) ->
		@opts = _.extend opts,
			cols: 40
			rows: 20
			game_speed: 0

	set_game_speed: (speed_idx) ->
		@game_speed = @game_speeds[speed_idx]

	create_snake: ->
		{
			x: @opts.cols / 2
			y: @opts.rows / 2
			x_velocity: 0 
			y_velocity: 0
			length: 2 
			speed: 1
			max_speed: 6
		}

	setup_events: ->
		up = [38]
		down = [40]
		left = [37]
		right = [39]

		$(document.body).on 'keydown', (e) =>
			if _.indexOf(up, e.keyCode) > -1 
				@move_snake 'up'
			if _.indexOf(down, e.keyCode) > -1 
				@move_snake 'down'
			if _.indexOf(left, e.keyCode) > -1 
				@move_snake 'left'
			if _.indexOf(right, e.keyCode) > -1 
				@move_snake 'right'


	set_snake_velocity: (x, y) ->
		@snake.x_velocity = x
		@snake.y_velocity = y

	move_snake: (dir) ->
		console.log 'move snake', dir
		north = ['n', 'north', 'up', 'u']
		east = ['e', 'east', 'right', 'r']
		west = ['w', 'west', 'left', 'l']
		south = ['s', 'south', 'down', 'd']

		if _.indexOf(north, dir) > -1 
			@set_snake_velocity 0, -1
		if _.indexOf(west, dir) > -1 
			@set_snake_velocity -1, 0
		if _.indexOf(east, dir) > -1 
			@set_snake_velocity 1, 0
		if _.indexOf(south, dir) > -1 
			@set_snake_velocity 0, 1

	update: ->
		fn = =>
			return if @paused
			
			@ticks += 1

			if @ticks % @game_speed == 0
				@snake.x = Math.max 0, Math.min @opts.cols - 1, @snake.x + @snake.x_velocity
				@snake.y = Math.max 0, Math.min @opts.rows - 1, @snake.y + @snake.y_velocity

			@render()

			@timeout = setTimeout fn, 1000 / 30

		fn()

	render: ->
		if !@rendered
			@rendered = true
			grid = []
			for y in [0...@opts.rows]	
				$row = $("<div/>").addClass("row").attr("data-y", y)

				for x in [0...@opts.cols]
					$grid = $("<div/>").addClass("cell").attr("data-x", x)	
					$row.append($grid)

				@container.append($row)

		@render_snake()

	render_snake: ->
		@container.find('.cell.snake').removeClass('snake')
		@container.find(".row[data-y=#{@snake.y}] .cell[data-x=#{@snake.x}]").addClass('snake')	
	

		
World = {}

$ ->
	World.snake = new SnakeGame "#snake"
