require 'uri'
require 'cgi'

puts "Starting image URL fix..."

fixed_count = 0
failed_count = 0

Recipe.find_each do |recipe|
  next if recipe.image.blank?

  # Check if it's a proxy URL
  if recipe.image.include?('imagesvc.meredithcorp.io')
    begin
      # Parse the URL
      uri = URI.parse(recipe.image)

      # Extract the 'url' parameter
      params = CGI.parse(uri.query)
      direct_url = params['url']&.first

      if direct_url
        # Update the recipe
        recipe.update_column(:image, direct_url)
        fixed_count += 1
        print "." if fixed_count % 100 == 0
      else
        failed_count += 1
      end
    rescue => e
      puts "\nError processing recipe #{recipe.id}: #{e.message}"
      failed_count += 1
    end
  end
end

puts "\n\nDone!"
puts "Fixed: #{fixed_count} recipes"
puts "Failed: #{failed_count} recipes"
