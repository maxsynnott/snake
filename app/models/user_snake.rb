class UserSnake
	include ActiveModel::Model

	attr_accessor :length, :board, :id, :endpoint

	def initialize(args)
		@length = args[:length] || 3
		@id = args[:id]
		@board = args[:board]
		@endpoint = args[:endpoint]
	end

	def fetch_move(board)
		parsed_response = HTTParty.post(@endpoint, {
			body: board.to_json,
			headers: { 'Content-Type' => 'application/json' }
		}).parsed_response

		@id.to_s + parsed_response["move"]
	end

	def find_snake_position
		[find_part(0), find_part(@length - 1)] # Head, Tail
	end

	def find_part(part_num)
		part = "#{@id}_#{part_num}"

		row = @board.data.find { |row| row.any? { |tile| tile.include?(part) } }

		if row
			tile = row.find { |tile| tile.include?(part) }

			y = @board.data.find_index(row)
			x = row.find_index(tile)
			i = tile.find_index(part)

			[x, y, i]
		end
	end

	def move_head(direction)
		x, y, _ = find_part(1)

		case direction
		when 'u'
			y -= 1
		when 'r'
			x += 1
		when 'd'
			y += 1
		when 'l'
			x -= 1
		end

		@board.data[y][x].try(:push, "#{@id}_0") if @board.data[y]
	end

	def remove_tail
		x, y, i = find_part(@length)

		@board.data[y][x].delete_at(i)
	end

	def update_body
		(0...@length).reverse_each do |part_num|
			x, y, i = find_part(part_num)

			@board.data[y][x][i].gsub!("_#{part_num}", "_#{part_num + 1}")
		end
	end

	def move(direction)
		update_body
		move_head(direction)
		remove_tail
	end

	def kill
		parts = (0...@length).to_a.map { |i| "#{@id}_#{i}" }
		@board.data.each { |row| row.each { |tile| tile -= parts } }
	end
end
