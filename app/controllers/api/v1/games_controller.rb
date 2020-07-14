class Api::V1::GamesController < ApplicationController
	def create
		user_ids = (1..params[:num_users]).to_a # Implement matchmaking logic later

		@game = Game.create(user_ids: user_ids)
	end

	def run
		@game = Game.find(params[:id])

		@game.run
	end
end
