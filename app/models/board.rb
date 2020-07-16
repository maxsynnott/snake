class Board
	include ActiveModel::Model

	attr_accessor :data, :size

	def initialize(args)
		@size = args[:size]

		@data = Array.new(@size) { Array.new(@size) { [] } }
	end
end