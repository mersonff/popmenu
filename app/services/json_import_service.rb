class JsonImportService
  def initialize(restaurant:, data:, logger: Rails.logger)
    @restaurant = restaurant
    @data = data
    @logger = logger
  end

  def call
    return Result.failure("Invalid data: expected a Hash with 'menus' key") unless valid_structure?

    item_results = []

    @data["menus"].each do |menu_data|
      menu = find_or_create_menu(menu_data)

      next unless menu

      (menu_data["menu_items"] || []).each do |item_data|
        result = import_item(menu, item_data)
        item_results << result
        log_item_result(result)
      end
    end

    summary = build_summary(item_results)
    Result.success(summary)
  end

  private

  def valid_structure?
    @data.is_a?(Hash) && @data["menus"].is_a?(Array)
  end

  def find_or_create_menu(menu_data)
    name = menu_data["name"]
    unless name.present?
      @logger.warn("Skipping menu with missing name")
      return nil
    end

    @restaurant.menus.find_or_create_by!(name: name)
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
        description: item_data["description"] || "",
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
