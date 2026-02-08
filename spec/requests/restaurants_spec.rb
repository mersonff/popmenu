require 'rails_helper'

RSpec.describe "Restaurants", type: :request do
  describe "GET /restaurants" do
    it "returns all restaurants" do
      create_list(:restaurant, 3)

      get "/restaurants"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"].size).to eq(3)
    end
  end

  describe "GET /restaurants/:id" do
    it "returns the restaurant" do
      restaurant = create(:restaurant)

      get "/restaurants/#{restaurant.id}"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["id"]).to eq(restaurant.id)
      expect(parsed_body["data"]["name"]).to eq(restaurant.name)
    end

    it "returns 404 for non-existent restaurant" do
      get "/restaurants/999"

      expect(response).to have_http_status(:not_found)
      expect(parsed_body["error"]["message"]).to be_present
    end
  end

  describe "POST /restaurants" do
    it "creates a restaurant" do
      params = { restaurant: { name: "Gourmet Place", address: "456 Oak St", phone: "555-1234" } }

      post "/restaurants", params: params, as: :json

      expect(response).to have_http_status(:created)
      expect(parsed_body["data"]["name"]).to eq("Gourmet Place")
    end

    it "returns 422 for invalid params" do
      params = { restaurant: { name: "" } }

      post "/restaurants", params: params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body["error"]["details"]).to be_present
    end
  end

  describe "PATCH /restaurants/:id" do
    it "updates the restaurant" do
      restaurant = create(:restaurant, name: "Old Name")

      patch "/restaurants/#{restaurant.id}", params: { restaurant: { name: "New Name" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["name"]).to eq("New Name")
    end
  end

  describe "DELETE /restaurants/:id" do
    it "deletes the restaurant" do
      restaurant = create(:restaurant)

      expect { delete "/restaurants/#{restaurant.id}" }.to change(Restaurant, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent restaurant" do
      delete "/restaurants/999"

      expect(response).to have_http_status(:not_found)
    end
  end

  private

  def parsed_body
    JSON.parse(response.body)
  end
end
