class AddBoardSizeToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :board_size, :integer, default: 50
  end
end
