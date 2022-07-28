class Ingredient < ApplicationRecord
	include RecipesHelper

	BASIC_INGREDIENTS = %w(salt pepper water)
	has_many :recipe_ingredients
	has_many :recipes, through: :recipe_ingredients

	validates :name, presence: true, uniqueness: true

	before_save :set_is_basic_ingredient_field

	scope :get_basic_ingredients, -> { where(is_basic_ingredient: true) }

	def self.search_by_name(item)
		Rails.cache.fetch(item, expires_in: 1.hour) do
			Ingredient.select(:id, :name)
					.select { |i| !i[:name].split(" ").select { |word| string_compare_metric(word,item) > 0.9 }.empty? }
					.pluck(:id)
		end
	end

	private

	def set_is_basic_ingredient_field
		self.is_basic_ingredient = basic_ingredient?
	end

	def basic_ingredient?
		BASIC_INGREDIENTS.any? { |ingredient| name.include?(ingredient) }
	end
end