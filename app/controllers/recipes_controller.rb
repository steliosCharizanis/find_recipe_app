class RecipesController < ApplicationController
  MAX_ITEMS = 50

  rescue_from StandardError, with: :handle_standard_error
  rescue_from ArgumentError, with: :handle_bad_request

  def index
  end

  def search
    validate_search_params!

    items = parse_items(params[:items])
    sort_by = params[:sortBy] || 'highest_rated'
    recipes = items.empty? ? [] : RecipesFinderService.new(items, params[:haveBasicIngredients], sort_by).call
    recipes = ActiveModelSerializers::SerializableResource.new(recipes, each_serializer: RecipeSerializer)

    render json: { recipes: recipes }, status: 200
  end

  private

  def validate_search_params!
    if params[:items].present?
      items_count = params[:items].split(',').length
      if items_count > MAX_ITEMS
        raise ArgumentError, "Too many items. Maximum #{MAX_ITEMS} allowed, got #{items_count}"
      end
    end
  end

  def parse_items(items_param)
    return [] if items_param.nil? || items_param.empty?

    items_param.split(',').map(&:strip).reject(&:empty?)
  end

  def handle_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def handle_standard_error(exception)
    Rails.logger.error("Search error: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))
    render json: { error: "An error occurred while processing your request" }, status: :internal_server_error
  end
end
