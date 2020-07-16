Rails.application.routes.draw do
	namespace :api do
		namespace :v1 do
			resources :games, only: [:create] do
				member do
					post 'run'
				end
			end
		end
	end
end
