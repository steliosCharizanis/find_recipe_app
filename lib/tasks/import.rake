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

	task recipes_with_i: :environment do
		puts 'start importing recipies...'
		recipes_to_import = []
		recipes_list.each do |r|
			ingredients = r.delete('ingredients')
			r_ingredients = Ingredient.where(name: ingredients)
			recipe = Recipe.new(r)
			recipe.ingredients = r_ingredients
			recipe.created_at = DateTime.now
			recipe.updated_at = DateTime.now
			recipes_to_import << recipe
		end
		
		result = Recipe.import recipes_to_import, batch_size: 1000
		puts "Finally imported #{result.ids.count} recipes"
	end

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

	task all: :environment do
		recipe_ingredients_to_insert = []
		recipes_list.each do |r|
			ingredients = r.delete('ingredients')
			recipe = Recipe.new(r)
			recipe.created_at = DateTime.now
			recipe.updated_at = DateTime.now
			ingredients.each do |i|
				existing_ingredient = Ingredient.find_by_name(i)
				ingredient = existing_ingredient.nil? ? Ingredient.new(name: i, created_at: DateTime.now, updated_at: DateTime.now) : existing_ingredient
				ingredient.run_callbacks(:save) { false }
				recipe_ingredients_to_insert << RecipeIngredient.new(recipe: recipe, ingredient: ingredient)
			end
		end
		x = RecipeIngredient.import recipe_ingredients_to_insert, batch_size: 1000
		puts x
	end
end