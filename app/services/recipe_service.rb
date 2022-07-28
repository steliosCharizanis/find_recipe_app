class RecipeService
	include RecipesHelper

	def initialize(ingredients_array, have_basic_ingredients, all_ingredients = Ingredient.select(:id, :name))
		@ingredients = ingredients_array
		@all_ingredients = all_ingredients
		@have_basic_ingredients = have_basic_ingredients
	end

	def find_recipes_one_query
		Recipe.joins(:recipe_ingredients)
			.left_outer_join_ingredients(all_ingredients.join(','))
			.where(id: recipe_ids)
			.select(:id, :title, :prep_time, :cook_time, :ratings, :image, "count(recipe_ingredients.ingredient_id) - count(i.id) as missing")
			.group_by_id
			.order_by_missing
			.order_by_ratings
			.limit(20)
			.map{ |r| Recipe.new(id: r.id, title: r.title, prep_time: r.prep_time, cook_time: r.cook_time, ratings: r.ratings, image: r.image, missing_ingredients_count: r.missing) }
	end

	def find_recipes
		if recipe_ids_with_all_ingredients.count > 19
			recipes_with_all_ingredients
		else
			recipes_with_all_ingredients + recipes_with_ingredients_missing
		end
	end

	def recipes_with_all_ingredients
		Recipe.where(id: recipe_ids_with_all_ingredients)
			.order_by_ratings
			.limit(20)
			.map{ |r| Recipe.new(id: r.id, title: r.title, prep_time: r.prep_time, cook_time: r.cook_time, ratings: r.ratings, image: r.image, missing_ingredients_count: 0) }
	end

	def recipes_with_ingredients_missing
		Recipe.joins(:recipe_ingredients)
		.where(id: recipe_ids)
		.where.not(recipe_ingredients: {ingredient_id: all_ingredients})
		.select(:id, :title, :prep_time, :cook_time, :ratings, :image, "count(ingredient_id) as missing")
		.group_by_id
		.order_by_missing
		.order_by_ratings
		.limit(20 - recipe_ids_with_all_ingredients.count)
		.map{ |r| Recipe.new(id: r.id, title: r.title, prep_time: r.prep_time, cook_time: r.cook_time, ratings: r.ratings, image: r.image, missing_ingredients_count: r.missing) }
	end

	def recipe_ids
		RecipeIngredient.where(ingredient_id: matching_ingredients).select(:recipe_id).pluck(:recipe_id).uniq
	end

	def recipe_ids_with_ingredients_missing
		RecipeIngredient.where(recipe_id: recipe_ids).where.not(ingredient_id: all_ingredients).select(:recipe_id).pluck(:recipe_id).uniq
	end

	def recipe_ids_with_all_ingredients
		recipe_ids - recipe_ids_with_ingredients_missing
	end

	def all_ingredients
		return matching_ingredients + basic_ingredient_ids if @have_basic_ingredients == 'true'
			
		matching_ingredients
	end

	def matching_ingredients
		ingredient_ids = []
		@ingredients.each { |i| ingredient_ids << ingredients_by_name(i) }
		ingredient_ids.flatten.uniq
	end

	def ingredients_by_name(ingredient)
		Rails.cache.fetch(ingredient, expires_in: 1.hour) do
			@all_ingredients
					.select { |i| !i[:name].split(" ").select { |word| string_compare_metric(word,ingredient) > 0.9 }.empty? }
					.pluck(:id).to_a
		end
	end

	def basic_ingredient_ids
		Rails.cache.fetch("basic_ingredient_ids", expires_in: 1.hour) do
			Ingredient.get_basic_ingredients.ids
		end
	end
end