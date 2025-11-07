class AddCompoundIndexToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_index :recipes, [:title, :author]
  end
end
