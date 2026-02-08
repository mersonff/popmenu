require 'rails_helper'

RSpec.describe "Menus", type: :request do
  describe "GET /menus" do
    it "returns all menus" do
      create_list(:menu, 3)

      get "/menus"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"].size).to eq(3)
    end
  end

  describe "GET /menus/:id" do
    it "returns the menu" do
      menu = create(:menu)

      get "/menus/#{menu.id}"

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["id"]).to eq(menu.id)
      expect(parsed_body["data"]["name"]).to eq(menu.name)
    end

    it "returns 404 for non-existent menu" do
      get "/menus/999"

      expect(response).to have_http_status(:not_found)
      expect(parsed_body["error"]["message"]).to be_present
    end
  end

  describe "POST /menus" do
    it "creates a menu" do
      params = { menu: { name: "Dinner", description: "Evening menu" } }

      post "/menus", params: params, as: :json

      expect(response).to have_http_status(:created)
      expect(parsed_body["data"]["name"]).to eq("Dinner")
      expect(parsed_body["data"]["active"]).to be true
    end

    it "returns 422 for invalid params" do
      params = { menu: { name: "" } }

      post "/menus", params: params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body["error"]["details"]).to be_present
    end
  end

  describe "PATCH /menus/:id" do
    it "updates the menu" do
      menu = create(:menu, name: "Old Name")

      patch "/menus/#{menu.id}", params: { menu: { name: "New Name" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(parsed_body["data"]["name"]).to eq("New Name")
    end

    it "returns 422 for invalid params" do
      menu = create(:menu)

      patch "/menus/#{menu.id}", params: { menu: { name: "" } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /menus/:id" do
    it "deletes the menu" do
      menu = create(:menu)

      expect { delete "/menus/#{menu.id}" }.to change(Menu, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent menu" do
      delete "/menus/999"

      expect(response).to have_http_status(:not_found)
    end
  end

  private

  def parsed_body
    JSON.parse(response.body)
  end
end
