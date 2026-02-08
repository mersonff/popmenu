require 'rails_helper'

RSpec.describe "MenuItems", type: :request do
  let(:restaurant) { create(:restaurant) }
  let(:menu) { create(:menu, restaurant: restaurant) }

  describe "GET /restaurants/:restaurant_id/menus/:menu_id/menu_items" do
    it "returns menu items for the menu" do
      items = create_list(:menu_item, 3)
      items.each { |item| create(:menu_item_placement, menu: menu, menu_item: item) }

      other_menu = create(:menu, restaurant: restaurant)
      other_item = create(:menu_item)
      create(:menu_item_placement, menu: other_menu, menu_item: other_item)

      get "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"].size).to eq(3)
    end
  end

  describe "GET /restaurants/:restaurant_id/menus/:menu_id/menu_items/:id" do
    it "returns the menu item" do
      item = create(:menu_item)
      create(:menu_item_placement, menu: menu, menu_item: item)

      get "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items/#{item.id}"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["id"]).to eq(item.id)
    end

    it "returns 404 for non-existent item" do
      get "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items/999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /restaurants/:restaurant_id/menus/:menu_id/menu_items" do
    it "creates a new menu item and places it on the menu" do
      params = { menu_item: { name: "Burger", description: "Juicy beef", price: 12.50 } }

      post "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items", params: params, as: :json

      expect(response).to have_http_status(:created)
      expect(parsed_body["data"]["name"]).to eq("Burger")
      expect(menu.menu_items.count).to eq(1)
    end

    it "reuses an existing menu item by name" do
      existing = create(:menu_item, name: "Burger", description: "Old desc", price: 10.00)
      params = { menu_item: { name: "Burger", description: "New desc", price: 12.50 } }

      expect {
        post "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items", params: params, as: :json
      }.not_to change(MenuItem, :count)

      expect(response).to have_http_status(:created)
      expect(existing.reload.description).to eq("New desc")
      expect(menu.menu_items).to include(existing)
    end

    it "does not duplicate placement if item already on menu" do
      item = create(:menu_item, name: "Burger", description: "Beef", price: 10.00)
      create(:menu_item_placement, menu: menu, menu_item: item)

      params = { menu_item: { name: "Burger", description: "Beef", price: 10.00 } }

      expect {
        post "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items", params: params, as: :json
      }.not_to change(MenuItemPlacement, :count)

      expect(response).to have_http_status(:created)
    end

    it "returns 422 for invalid params" do
      params = { menu_item: { name: "" } }

      post "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items", params: params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body["error"]["details"]).to be_present
    end

    it "returns 422 for negative price" do
      params = { menu_item: { name: "Bad", description: "Nope", price: -1 } }

      post "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items", params: params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /restaurants/:restaurant_id/menus/:menu_id/menu_items/:id" do
    it "updates the menu item" do
      item = create(:menu_item)
      create(:menu_item_placement, menu: menu, menu_item: item)

      patch "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items/#{item.id}",
            params: { menu_item: { price: 15.00 } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["price"]).to eq("15.0")
    end
  end

  describe "DELETE /restaurants/:restaurant_id/menus/:menu_id/menu_items/:id" do
    it "removes the placement but not the menu item" do
      item = create(:menu_item)
      create(:menu_item_placement, menu: menu, menu_item: item)

      expect {
        delete "/restaurants/#{restaurant.id}/menus/#{menu.id}/menu_items/#{item.id}"
      }.to change(MenuItemPlacement, :count).by(-1)
        .and change(MenuItem, :count).by(0)

      expect(response).to have_http_status(:no_content)
    end
  end

  private

  def parsed_body
    JSON.parse(response.body)
  end
end
