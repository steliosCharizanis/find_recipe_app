class RecipeSerializer < ActiveModel::Serializer
	attributes :id, :title, :total_time, :ratings, :image, :missing_ingredients_count, :missing_ingredients_text

	def missing_ingredients_count
		object.missing_ingredients_count
	end

	def missing_ingredients_text
		if object.missing_ingredients_count == 0
			"You have all Ingredients!!"
		else
			if object.missing_ingredients_count == 1 
				"missing #{object.missing_ingredients_count} ingredient"
			else
				"missing #{object.missing_ingredients_count} ingredients"
			end
		end
	end

	def total_time
		object.cook_time + object.prep_time
	end

	def ratings
		object.ratings
	end

end