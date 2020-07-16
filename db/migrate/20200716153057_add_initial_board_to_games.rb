class AddInitialBoardToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :initial_board, :string
  end
end
