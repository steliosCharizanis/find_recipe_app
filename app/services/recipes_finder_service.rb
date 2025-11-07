class RecipesFinderService
	include RecipesHelper

	def initialize(ingredients_array, have_basic_ingredients, all_ingredients = Ingredient.select(:id, :name))
		@ingredients = ingredients_array
		@all_ingredients = all_ingredients
		@have_basic_ingredients = have_basic_ingredients
	end

	def call
		cache_key = generate_cache_key

		Rails.cache.fetch(cache_key, expires_in: 1.hour) do
			find_recipes_one_query
		end
	end

	private

	def generate_cache_key
		ingredients_key = @ingredients.sort.join(',')
		"recipe_search:#{ingredients_key}:basic_#{@have_basic_ingredients}"
	end

	def find_recipes_one_query
		Recipe.joins(:recipe_ingredients)
			.containing_ingredient_ids(all_ingredients.join(','))
			.where(id: RecipeIngredient.where(ingredient_id: matching_ingredients).select(:recipe_id))
			.select(:id, :title, :prep_time, :cook_time, :ratings, :image, "count(recipe_ingredients.ingredient_id) - count(i.id) as missing")
			.group_by_id
			.order_by_missing
			.order_by_ratings
			.limit(20)
			.map{ |r| Recipe.new(id: r.id, title: r.title, prep_time: r.prep_time, cook_time: r.cook_time, ratings: r.ratings, image: r.image, missing_ingredients_count: r.missing) }
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