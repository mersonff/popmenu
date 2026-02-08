require 'rails_helper'

RSpec.describe "Menus", type: :request do
  let(:restaurant) { create(:restaurant) }

  describe "GET /restaurants/:restaurant_id/menus" do
    it "returns menus for the restaurant" do
      create_list(:menu, 3, restaurant: restaurant)
      create(:menu) # different restaurant

      get "/restaurants/#{restaurant.id}/menus"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"].size).to eq(3)
    end
  end

  describe "GET /restaurants/:restaurant_id/menus/:id" do
    it "returns the menu" do
      menu = create(:menu, restaurant: restaurant)

      get "/restaurants/#{restaurant.id}/menus/#{menu.id}"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["id"]).to eq(menu.id)
      expect(parsed_body["data"]["name"]).to eq(menu.name)
    end

    it "returns 404 for non-existent menu" do
      get "/restaurants/#{restaurant.id}/menus/999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /restaurants/:restaurant_id/menus" do
    it "creates a menu" do
      params = { menu: { name: "Dinner", description: "Evening menu" } }

      post "/restaurants/#{restaurant.id}/menus", params: params, as: :json

      expect(response).to have_http_status(:created)
      expect(parsed_body["data"]["name"]).to eq("Dinner")
      expect(parsed_body["data"]["active"]).to be true
    end

    it "returns 422 for invalid params" do
      params = { menu: { name: "" } }

      post "/restaurants/#{restaurant.id}/menus", params: params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body["error"]["details"]).to be_present
    end
  end

  describe "PATCH /restaurants/:restaurant_id/menus/:id" do
    it "updates the menu" do
      menu = create(:menu, restaurant: restaurant, name: "Old Name")

      patch "/restaurants/#{restaurant.id}/menus/#{menu.id}",
            params: { menu: { name: "New Name" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["name"]).to eq("New Name")
    end

    it "returns 422 for invalid params" do
      menu = create(:menu, restaurant: restaurant)

      patch "/restaurants/#{restaurant.id}/menus/#{menu.id}",
            params: { menu: { name: "" } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /restaurants/:restaurant_id/menus/:id" do
    it "deletes the menu" do
      menu = create(:menu, restaurant: restaurant)

      expect { delete "/restaurants/#{restaurant.id}/menus/#{menu.id}" }
        .to change(Menu, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent menu" do
      delete "/restaurants/#{restaurant.id}/menus/999"

      expect(response).to have_http_status(:not_found)
    end
  end

  private

  def parsed_body
    JSON.parse(response.body)
  end
end
