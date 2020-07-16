class Game < ApplicationRecord
	def users
		@users = HTTParty.get("http://localhost:4000/api/v1/users?ids=#{user_ids.join(',')}").parsed_response
	end

	def init_user_snakes
		@user_snakes = users.map { |user| UserSnake.new(id: user["id"], endpoint: user["endpoint"], board: @board) }
	end

	def init_board
		@board = Board.new(size: board_size)
	end

	def random_tile
		y = @board.data.map.with_index { |row, i| i unless row.count(&:empty?).zero? }.compact.sample
		x = @board.data[y].map.with_index { |t, i| i if t.empty? }.compact.sample

		[x, y]
	end

	def assign_starter_positions
		# Currently only works for length of 3 and is super janky, needs reworking
		@user_snakes.each do |user_snake|
			x, y = random_tile

			checks = [
				[[0, -1], [0, -2]],
				[[-1, 0], [-2, 0]],
			  [[0, 1], [0, 2]],
			  [[1, 0], [2, 0]]
			].shuffle

			clear_check = checks.find do |check| 
				check.all? do |adj|
					adj_x = x + adj[0]
					adj_y = y + adj[1]

					unless adj_x.negative? or adj_y.negative?
						@board.data[adj_y][adj_x].try(:empty?) if @board.data[adj_y]
					end
				end
			end

			@board.data[y][x] << "#{user_snake.id}_0"
			@board.data[y + clear_check[0][1]][x + clear_check[0][0]] << "#{user_snake.id}_1"
			@board.data[y + clear_check[1][1]][x + clear_check[1][0]] << "#{user_snake.id}_2"
		end
	end

	def id_to_user_snake(id)
		@user_snakes.find { |user_snake| user_snake.id == id }
	end

	def run
		init_board
		init_user_snakes
		assign_starter_positions

		result = {
			history: [],
			initial_board: @board.data.clone.map { |row| row.map { |tile| tile.map(&:clone) } }
		}

		history = []

		until game_over or history.count > 1000
			moves = []

			@user_snakes.map { |user_snake| Thread.new { moves << user_snake.fetch_move(@board) } }.each(&:join)

			result[:history] << moves

			simulate_moves(moves)
		end


		result[:winner_id] = @user_snakes[0].try(:id)

		result
	end

	def game_over
		@user_snakes.count < 2
	end

	def simulate_moves(moves)
		moves.each do |move|
			direction = move[-1]
			user_snake = id_to_user_snake(move[0...-1].to_i)

			user_snake.move(direction)
		end

		assess_board
	end

	def assess_board
		dead_snakes = []

		@board.data.each do |row|
			row.each do |tile|
				if tile.count > 1
					tile.each do |piece|
						if piece.ends_with?("_0")
							dead_snakes << id_to_user_snake(piece[0...-2].to_i) 
						end
					end
				end
			end
		end

		@user_snakes.each do |user_snake|
			unless user_snake.find_part(0)
				dead_snakes << user_snake
			end
		end

		kill_snakes(dead_snakes.compact.uniq)
	end

	def kill_snakes(dead_snakes)
		dead_snakes.each(&:kill)
		@user_snakes -= dead_snakes
	end
end
