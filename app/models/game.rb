class Game < ApplicationRecord
	def users
		HTTParty.get("http://localhost:4000/api/v1/users?ids=#{user_ids.join(',')}").parsed_response
	end

	def init_snakes
		@snakes = users.map { |user| UserSnake.new(id: user["id"], endpoint: user["endpoint"], board: @board) }
	end

	def init_board
		@board = Array.new(board_size) { Array.new(board_size) }
	end

	def random_tile
		y = @board.map.with_index { |row, i| i unless row.count(nil).zero? }.sample
		x = @board[y].map.with_index { |t, i| i if t.nil? }.compact.sample

		[x, y]
	end

	def assign_starter_positions
		@snakes.each do |snake|
			x, y = random_tile
			@board[y][x] = snake.id.to_s + 'h'
		end
	end

	def idToSnake(id)
		@snakes.find { |snake| snake.id == id }
	end

	def run
		init_board
		init_snakes
		assign_starter_positions

		history = []

		until game_over 
			moves = []

			@snakes.each { |snake| Thread.new { moves << snake.fetch_move } }.each(&:join)

			simulate_moves(moves)
		end
	end

	def game_over
		@snakes.count == 1
		(0..50).to_a.sample.zero?
	end

	def simulate_moves(moves)
		sim_board = @board.clone.map(&:clone)

		moves.each do |move|
			snake = idToSnake(move[0..-2].to_i)
			direction = move[-1]

			snake.sim_move(sim_board, direction)
		end
	end
end
