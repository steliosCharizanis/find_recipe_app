class Recipe < ApplicationRecord
	attr_accessor :missing_ingredients_count

	has_many :recipe_ingredients
	has_many :ingredients, through: :recipe_ingredients

	validates :title, presence: true
	validates :ratings, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
	validates :cook_time, :prep_time, presence: true, numericality: { only_integer: true }

	#scope :available_for_charging, -> (business) { where(business_id: business.id, processed: false, invoice_excluded: false, billing_transaction: nil) }
	scope :containing_ingredient_ids, -> (ingredient_ids) { joins("left join ingredients i on i.id = recipe_ingredients.ingredient_id and i.id in (#{ingredient_ids})") }
	scope :group_by_id, -> { group(:id) }
	scope :order_by_missing, -> { order("missing")}
	scope :order_by_ratings, -> { order(ratings: :desc) }

end