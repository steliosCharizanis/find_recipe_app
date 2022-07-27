require 'fuzzystringmatch'

module RecipesHelper
	def string_compare_metric(string_a, string_b)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    jarow.getDistance(string_a, string_b)
  end
end