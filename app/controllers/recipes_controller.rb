class RecipesController < ApplicationController

  def index
  end

  def search
    recipes = params[:items].nil? || params[:items].empty? ? [] : RecipesFinderService.new(params[:items].split(','), params[:haveBasicIngredients]).call
    recipes = ActiveModelSerializers::SerializableResource.new(recipes, each_serializer: RecipeSerializer)
    render json: { recipes: recipes }, status: 200
  end
end
