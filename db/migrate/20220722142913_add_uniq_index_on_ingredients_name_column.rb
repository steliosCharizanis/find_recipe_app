class AddUniqIndexOnIngredientsNameColumn < ActiveRecord::Migration[6.1]
  def change
    add_index :ingredients, :name, unique: true
  end
end
