namespace :import_associations do
	desc 'Import recipes associations data from json file'

	recipes_list = JSON.parse(File.read('db/recipes-en.json'))

	task recipe_ingredients: :environment do
		puts 'importing associations...'
		associations_to_import = []
		recipes_list.each do |r|
			r_id = Recipe.where(title: r['title'], author: r['author']).select(:id).take

			ingredients_ids = Ingredient.where(name: r['ingredients']).select(:id)
			puts r['title'] + ", " + r['author'] if r_id.nil?
			ingredients_ids.each { |i| associations_to_import << RecipeIngredient.new(recipe_id: r_id.id, ingredient_id: i.id, created_at: DateTime.now, updated_at: DateTime.now)}
		end

		result = RecipeIngredient.import associations_to_import, batch_size: 1000
		puts "Finally imported #{result.ids.count} associations"
	end
end