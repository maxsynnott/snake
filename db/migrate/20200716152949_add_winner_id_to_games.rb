class AddWinnerIdToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :winner_id, :integer
  end
end
