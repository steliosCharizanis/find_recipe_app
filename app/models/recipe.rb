class Recipe < ApplicationRecord
	attr_accessor :missing_ingredients_count

	has_many :recipe_ingredients
	has_many :ingredients, through: :recipe_ingredients

	validates :title, presence: true
	validates :ratings, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
	validates :cook_time, :prep_time, presence: true, numericality: { only_integer: true }


end