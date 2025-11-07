class AddCompoundIndexToRecipeIngredients < ActiveRecord::Migration[6.1]
  def change
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id]
  end
end
