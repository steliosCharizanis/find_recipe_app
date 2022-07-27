class AddIsBasicIngredientFieldOnIngredients < ActiveRecord::Migration[6.1]
  def change
    add_column :ingredients, :is_basic_ingredient, :boolean, default: false
  end
end
