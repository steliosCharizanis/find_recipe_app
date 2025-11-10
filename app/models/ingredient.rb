class Ingredient < ApplicationRecord
	BASIC_INGREDIENTS = %w(salt pepper water)
	has_many :recipe_ingredients
	has_many :recipes, through: :recipe_ingredients

	validates :name, presence: true, uniqueness: true

	before_save :set_is_basic_ingredient_field

	scope :get_basic_ingredients, -> { where(is_basic_ingredient: true) }

	def self.search_by_name(query)
		Rails.cache.fetch("ingredient_fts:#{query}", expires_in: 1.hour) do
			# Use PostgreSQL full-text search with tsvector
			where("name_tsv @@ plainto_tsquery('english', ?)", query)
				.order(Arel.sql("ts_rank(name_tsv, plainto_tsquery('english', #{connection.quote(query)})) DESC"))
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