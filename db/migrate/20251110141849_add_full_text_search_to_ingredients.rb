class AddFullTextSearchToIngredients < ActiveRecord::Migration[6.1]
  def up
    # Add tsvector column for full-text search
    add_column :ingredients, :name_tsv, :tsvector

    # Populate the column with existing data
    execute <<-SQL
      UPDATE ingredients
      SET name_tsv = to_tsvector('english', coalesce(name, ''));
    SQL

    # Add GIN index for fast searching
    add_index :ingredients, :name_tsv, using: :gin

    # Keep it updated automatically with triggers
    execute <<-SQL
      CREATE TRIGGER ingredients_name_tsv_update
      BEFORE INSERT OR UPDATE ON ingredients
      FOR EACH ROW EXECUTE FUNCTION
      tsvector_update_trigger(name_tsv, 'pg_catalog.english', name);
    SQL
  end

  def down
    # Remove trigger
    execute "DROP TRIGGER IF EXISTS ingredients_name_tsv_update ON ingredients;"

    # Remove index
    remove_index :ingredients, :name_tsv

    # Remove column
    remove_column :ingredients, :name_tsv
  end
end
