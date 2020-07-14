class UserSnake
	include ActiveModel::Model

	attr_accessor :length, :board, :id, :endpoint

	def initialize(args)
		@length = args[:length] || 1
		@board = args[:board]
		@id = args[:id]
		@endpoint = args[:endpoint]
	end

	def fetch_move
		parsed_response = HTTParty.post(@endpoint, {
			body: @board.to_json,
			headers: { 'Content-Type' => 'application/json' }
		}).parsed_response

		@id.to_s + parsed_response["move"]
	end

	def move(board, direction)
		
	end
end
