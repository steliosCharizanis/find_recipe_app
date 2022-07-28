require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  describe "GET /recipes" do
    before do
      ingredient_1 = Ingredient.create(name: '10 eggs')
      ingredient_2 = Ingredient.create(name: '1 cup of milk')
      ingredient_3 = Ingredient.create(name: 'salt')
      Recipe.create(title: 'Test Recipe', cook_time: 15, prep_time: 10, ratings: 4.5, ingredients: [ingredient_1, ingredient_2, ingredient_3])

      get '/search'
    end

    it "returns 200 ok" do
      expect(response).to have_http_status(200)
    end

    it "returns empty recipes array if items are empty" do
      get '/search?items='
      expect(JSON(response.body)['recipes']).to eq([])
    end

    describe "return correct num of missing ingredients" do
      xit 'with haveBasicIngredients false' do
        #TODO
      end
      xit 'with haveBasicIngredients true' do
        #TODO
      end
    end

    xit "calculates correct the total_time" do
      #TODO
    end

    
  end
end
