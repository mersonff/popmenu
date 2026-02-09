require 'rails_helper'

RSpec.describe "Imports", type: :request do
  include ActiveJob::TestHelper

  describe "POST /imports" do
    it "returns 202 with pending status" do
      data = JSON.parse(file_fixture("valid_import.json").read)

      post "/imports", params: data, as: :json

      expect(response).to have_http_status(:accepted)
      body = parsed_body["data"]
      expect(body["id"]).to be_present
      expect(body["status"]).to eq("pending")
    end

    it "enqueues an ImportJob" do
      data = JSON.parse(file_fixture("valid_import.json").read)

      expect {
        post "/imports", params: data, as: :json
      }.to have_enqueued_job(ImportJob)
    end
  end

  describe "GET /imports/:id" do
    it "returns completed status with result after job runs" do
      data = JSON.parse(file_fixture("multi_restaurant_import.json").read)

      perform_enqueued_jobs do
        post "/imports", params: data, as: :json
      end

      id = parsed_body["data"]["id"]
      get "/imports/#{id}"

      expect(response).to have_http_status(:ok)
      body = parsed_body["data"]
      expect(body["status"]).to eq("completed")
      expect(body["result"]["restaurants_created"]).to eq(2)
      expect(body["result"]["total"]).to eq(5)
      expect(body["result"]["created"]).to eq(4)
      expect(body["result"]["existing"]).to eq(1)
      expect(body["result"]["failed"]).to eq(0)
    end

    it "returns failed status with error for malformed data" do
      data = JSON.parse(file_fixture("malformed_import.json").read)

      perform_enqueued_jobs do
        post "/imports", params: data, as: :json
      end

      id = parsed_body["data"]["id"]
      get "/imports/#{id}"

      expect(response).to have_http_status(:ok)
      body = parsed_body["data"]
      expect(body["status"]).to eq("failed")
      expect(body["error_message"]).to match(/Invalid data/)
    end

    it "returns pending status before job runs" do
      data = JSON.parse(file_fixture("valid_import.json").read)

      post "/imports", params: data, as: :json

      id = parsed_body["data"]["id"]
      get "/imports/#{id}"

      body = parsed_body["data"]
      expect(body["status"]).to eq("pending")
    end

    it "handles partial failures within a valid import" do
      data = JSON.parse(file_fixture("invalid_import.json").read)

      perform_enqueued_jobs do
        post "/imports", params: data, as: :json
      end

      id = parsed_body["data"]["id"]
      get "/imports/#{id}"

      body = parsed_body["data"]
      expect(body["status"]).to eq("completed")
      expect(body["result"]["failed"]).to eq(1)
      expect(body["result"]["created"]).to eq(1)
    end

    it "accepts 'dishes' as alias for 'menu_items'" do
      data = {
        "restaurants" => [
          {
            "name" => "Test Place",
            "menus" => [
              {
                "name" => "tapas",
                "dishes" => [
                  { "name" => "Patatas Bravas", "price" => 7.00 }
                ]
              }
            ]
          }
        ]
      }

      perform_enqueued_jobs do
        post "/imports", params: data, as: :json
      end

      id = parsed_body["data"]["id"]
      get "/imports/#{id}"

      body = parsed_body["data"]
      expect(body["status"]).to eq("completed")
      expect(body["result"]["created"]).to eq(1)
      expect(MenuItem.find_by(name: "Patatas Bravas")).to be_present
    end

    it "is idempotent: re-import marks all items as existing" do
      data = JSON.parse(file_fixture("multi_restaurant_import.json").read)

      perform_enqueued_jobs do
        post "/imports", params: data, as: :json
      end

      perform_enqueued_jobs do
        post "/imports", params: data, as: :json
      end

      id = parsed_body["data"]["id"]
      get "/imports/#{id}"

      body = parsed_body["data"]
      expect(body["status"]).to eq("completed")
      expect(body["result"]["restaurants_created"]).to eq(0)
      expect(body["result"]["created"]).to eq(0)
      expect(body["result"]["existing"]).to eq(5)
    end
  end

  private

  def parsed_body
    JSON.parse(response.body)
  end
end
