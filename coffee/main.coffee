class SnakeGame
	constructor: (container, opts={}) ->
		@container = $ container
		@set_opts opts
		@snake = @create_snake()
		@apple = @create_apple()
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
			moved: true
			positions: []
		}

	create_apple: ->
		x = Math.floor Math.random() * @opts.cols
		y = Math.floor Math.random() * @opts.rows

		{
			x: x
			y: y
			moved: true
			eaten: false
		}

	move_apple: ->
		@apple = @create_apple()

	setup_events: ->
		up = [38]
		down = [40]
		left = [37]
		right = [39]

		$(document.body).on 'keydown', (e) =>
			# console.log e.keyCode
			if _.indexOf(up, e.keyCode) > -1 
				@move_snake 'up'
			else if _.indexOf(down, e.keyCode) > -1 
				@move_snake 'down'
			else if _.indexOf(left, e.keyCode) > -1 
				@move_snake 'left'
			else if _.indexOf(right, e.keyCode) > -1 
				@move_snake 'right'
			else if e.keyCode == 32
				@paused = !@paused
			else if e.keyCode == 27
				@reset()

	reset: ->
		@paused = true
		@snake = @create_snake()
		@apple = @create_apple()

	set_snake_velocity: (x, y) ->
		@snake.x_velocity = x
		@snake.y_velocity = y

	move_snake: (dir) ->
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
			@ticks += 1

			if !@paused && @ticks % @game_speed == 0
				@update_snake()
				@update_apple()
				@did_snake_eat_apple()

			@render() if !@paused

			@timeout = setTimeout fn, 1000 / 30

		fn()

	update_snake: ->
		start_x = @snake.x
		start_y = @snake.y
		@snake.positions.push [start_x, start_y]
		@snake.x = Math.max 0, Math.min @opts.cols - 1, @snake.x + @snake.x_velocity
		@snake.y = Math.max 0, Math.min @opts.rows - 1, @snake.y + @snake.y_velocity
		@snake.moved = @snake.x != start_x || @snake.y != start_y

	update_apple: ->
		if @apple.eaten
			@move_apple()
			@grow_snake()

	did_snake_eat_apple: ->
		if @snake.x == @apple.x && @snake.y == @apple.y
			@apple.eaten = true

	grow_snake: (amount=1) ->
		@snake.length += amount

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
		@render_apple()

	cell_selector: (x, y) ->
		".row[data-y=#{y}] .cell[data-x=#{x}]"

	render_snake: ->
		if @snake.moved
			@snake.moved = false

			@container.find('.cell.snake').removeClass('snake')
			@container.find(@cell_selector(@snake.x, @snake.y)).addClass('snake')	

			for i in [1..@snake.length]
				if @snake.positions.length
					x = @snake.positions[@snake.positions.length - i][0]
					y = @snake.positions[@snake.positions.length - i][1]
				@container.find(@cell_selector(x, y)).addClass('snake')

	render_apple: ->
		if @apple.moved
			@apple.moved = false

			@container.find('.cell.apple').removeClass('apple')
			@container.find(@cell_selector(@apple.x, @apple.y)).addClass('apple')
	

		
World = {}

$ ->
	World.snake = new SnakeGame "#snake"
