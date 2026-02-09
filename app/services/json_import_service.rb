class JsonImportService
  def initialize(data:, logger: Rails.logger)
    @data = data
    @logger = logger
  end

  def call
    return Result.failure("Invalid data: expected a Hash with 'restaurants' key") unless valid_structure?

    item_results = []
    restaurants_created = 0

    @data["restaurants"].each do |restaurant_data|
      name = restaurant_data["name"]
      unless name.present?
        @logger.warn("Skipping restaurant with missing name")
        next
      end

      restaurant = Restaurant.find_or_initialize_by(name: name)
      if restaurant.new_record?
        restaurant.save!
        restaurants_created += 1
        @logger.info("Created restaurant: #{name}")
      else
        @logger.info("Existing restaurant: #{name}")
      end

      (restaurant_data["menus"] || []).each do |menu_data|
        menu = find_or_create_menu(restaurant, menu_data)
        next unless menu

        items = menu_data["menu_items"] || menu_data["dishes"] || []
        seen_names = Set.new

        items.each do |item_data|
          item_name = item_data["name"]
          if item_name.present? && seen_names.include?(item_name)
            @logger.info("Skipping duplicate item in batch: #{item_name}")
            next
          end
          seen_names.add(item_name)

          result = import_item(menu, item_data)
          item_results << result
          log_item_result(result)
        end
      end
    end

    summary = build_summary(item_results).merge(restaurants_created: restaurants_created)
    Result.success(summary)
  end

  private

  def valid_structure?
    @data.is_a?(Hash) && @data["restaurants"].is_a?(Array)
  end

  def find_or_create_menu(restaurant, menu_data)
    name = menu_data["name"]
    unless name.present?
      @logger.warn("Skipping menu with missing name")
      return nil
    end

    restaurant.menus.find_or_create_by!(name: name)
  end

  def import_item(menu, item_data)
    name = item_data["name"]
    return ImportItemResult.new(status: :failed, name: name || "unknown", error: "Missing item name") unless name.present?

    menu_item = MenuItem.find_by(name: name)

    if menu_item
      place_item(menu, menu_item)
      ImportItemResult.new(status: :existing, name: name)
    else
      menu_item = MenuItem.create!(
        name: name,
        description: item_data["description"].presence || "No description",
        price: item_data["price"] || 0
      )
      menu.menu_items << menu_item
      ImportItemResult.new(status: :created, name: name)
    end
  rescue ActiveRecord::RecordInvalid => e
    ImportItemResult.new(status: :failed, name: name, error: e.message)
  end

  def place_item(menu, menu_item)
    menu.menu_items << menu_item unless menu.menu_items.include?(menu_item)
  end

  def log_item_result(result)
    case result.status
    when :created
      @logger.info("Created item: #{result.name}")
    when :existing
      @logger.info("Existing item: #{result.name}")
    when :failed
      @logger.warn("Failed to import item '#{result.name}': #{result.error}")
    end
  end

  def build_summary(item_results)
    {
      total: item_results.size,
      created: item_results.count(&:created?),
      existing: item_results.count(&:existing?),
      failed: item_results.count(&:failed?),
      items: item_results.map(&:to_h)
    }
  end
end
