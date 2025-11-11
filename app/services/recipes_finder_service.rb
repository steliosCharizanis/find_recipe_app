class RecipesFinderService
	def initialize(ingredients_array, have_basic_ingredients, sort_by = 'highest_rated')
		@ingredients = ingredients_array
		@have_basic_ingredients = have_basic_ingredients
		@sort_by = sort_by
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
		"recipe_search:#{ingredients_key}:basic_#{@have_basic_ingredients}:sort_#{@sort_by}"
	end

	def find_recipes_one_query
		# Return empty array if no matching ingredients found
		return [] if matching_ingredients.empty?

		query = Recipe.joins(:recipe_ingredients)
			.containing_ingredient_ids(all_ingredients.join(','))
			.where(id: RecipeIngredient.where(ingredient_id: matching_ingredients).select(:recipe_id))
			.select(:id, :title, :prep_time, :cook_time, :ratings, :image, "count(recipe_ingredients.ingredient_id) - count(i.id) as missing")
			.group_by_id

		# Always sort by fewest missing ingredients first, then by user preference
		query = case @sort_by
		when 'quickest'
			query.order_by_missing.order(Arel.sql("(recipes.prep_time + recipes.cook_time) ASC"))
		else # 'highest_rated' (default)
			query.order_by_missing.order_by_ratings
		end

		query.limit(20)
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
		# Delegate to Ingredient model which now uses full-text search
		Ingredient.search_by_name(ingredient)
	end

	def basic_ingredient_ids
		Rails.cache.fetch("basic_ingredient_ids", expires_in: 1.hour) do
			Ingredient.get_basic_ingredients.ids
		end
	end
end