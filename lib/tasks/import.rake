namespace :import do
	desc 'Import recipes data from json file'

	recipes_list = JSON.parse(File.read('db/recipes-en.json'))

	task ingredients: :environment do
		puts 'Start importing ingredients...'
		ingredients_list = recipes_list.pluck('ingredients').flatten
		ingredients_list_uniq = ingredients_list.uniq
		ingredients_to_import = []
		ingredients_list_uniq.each { |i| ingredients_to_import << Ingredient.new(name: i, created_at: DateTime.now, updated_at: DateTime.now) }
		ingredients_to_import.each { |i| i.run_callbacks(:save) { false } }
		result = Ingredient.import ingredients_to_import, batch_size: 1000
		puts "Finally imported #{result.ids.count} ingredients"
	end

	task recipes: :environment do
		puts 'start importing recipies...'
		recipes_to_import = []
		recipes_list.each do |r|
			r.delete('ingredients')
			recipe = Recipe.new(r)
			recipe.created_at = DateTime.now
			recipe.updated_at = DateTime.now
			recipes_to_import << recipe
		end

		result = Recipe.import recipes_to_import, batch_size: 1000
		puts "Finally imported #{result.ids.count} recipes"
	end
end