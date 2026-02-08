require 'rails_helper'

RSpec.describe "MenuItems", type: :request do
  let(:menu) { create(:menu) }

  describe "GET /menus/:menu_id/menu_items" do
    it "returns menu items for the menu" do
      create_list(:menu_item, 3, menu: menu)
      create(:menu_item) # different menu

      get "/menus/#{menu.id}/menu_items"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"].size).to eq(3)
    end
  end

  describe "GET /menus/:menu_id/menu_items/:id" do
    it "returns the menu item" do
      item = create(:menu_item, menu: menu)

      get "/menus/#{menu.id}/menu_items/#{item.id}"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["id"]).to eq(item.id)
    end

    it "returns 404 for non-existent item" do
      get "/menus/#{menu.id}/menu_items/999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /menus/:menu_id/menu_items" do
    it "creates a menu item" do
      params = { menu_item: { name: "Burger", description: "Juicy beef", price: 12.50 } }

      post "/menus/#{menu.id}/menu_items", params: params, as: :json

      expect(response).to have_http_status(:created)
      expect(parsed_body["data"]["name"]).to eq("Burger")
      expect(parsed_body["data"]["price"]).to eq("12.5")
    end

    it "returns 422 for invalid params" do
      params = { menu_item: { name: "" } }

      post "/menus/#{menu.id}/menu_items", params: params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body["error"]["details"]).to be_present
    end

    it "returns 422 for negative price" do
      params = { menu_item: { name: "Bad", description: "Nope", price: -1 } }

      post "/menus/#{menu.id}/menu_items", params: params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /menus/:menu_id/menu_items/:id" do
    it "updates the menu item" do
      item = create(:menu_item, menu: menu)

      patch "/menus/#{menu.id}/menu_items/#{item.id}",
            params: { menu_item: { price: 15.00 } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["price"]).to eq("15.0")
    end
  end

  describe "DELETE /menus/:menu_id/menu_items/:id" do
    it "deletes the menu item" do
      item = create(:menu_item, menu: menu)

      expect { delete "/menus/#{menu.id}/menu_items/#{item.id}" }
        .to change(MenuItem, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  private

  def parsed_body
    JSON.parse(response.body)
  end
end
