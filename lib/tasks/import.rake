namespace :import do
  desc "Import restaurant data from a JSON file"
  task :json, [:restaurant_id, :file_path] => :environment do |_t, args|
    restaurant_id = args[:restaurant_id]
    file_path = args[:file_path]

    abort "Usage: bin/rails import:json[restaurant_id,file_path]" unless restaurant_id && file_path
    abort "File not found: #{file_path}" unless File.exist?(file_path)

    restaurant = Restaurant.find(restaurant_id)
    data = JSON.parse(File.read(file_path))
    logger = Logger.new($stdout)

    result = JsonImportService.new(restaurant: restaurant, data: data, logger: logger).call

    if result.success?
      summary = result.data
      logger.info("Import complete: #{summary[:total]} items (#{summary[:created]} created, #{summary[:existing]} existing, #{summary[:failed]} failed)")
    else
      logger.error("Import failed: #{result.error}")
      exit 1
    end
  end
end
