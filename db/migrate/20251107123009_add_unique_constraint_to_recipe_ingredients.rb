class AddUniqueConstraintToRecipeIngredients < ActiveRecord::Migration[6.1]
  def change
    # Remove the non-unique compound index added earlier
    remove_index :recipe_ingredients, [:recipe_id, :ingredient_id]

    # Add unique index (serves both as index and uniqueness constraint)
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id], unique: true, name: 'index_recipe_ingredients_uniqueness'
  end
end
