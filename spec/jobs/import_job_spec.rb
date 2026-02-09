require 'rails_helper'

RSpec.describe ImportJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    it "transitions pending → processing → completed with valid data" do
      data = JSON.parse(file_fixture("valid_import.json").read)
      import = Import.create!(input_data: data)

      perform_enqueued_jobs { ImportJob.perform_later(import.id) }

      import.reload
      expect(import.status).to eq("completed")
      expect(import.result_data).to be_present
      expect(import.result_data["created"]).to eq(3)
      expect(import.error_message).to be_nil
    end

    it "transitions pending → processing → failed with malformed data" do
      import = Import.create!(input_data: { "invalid_key" => "no menus here" })

      perform_enqueued_jobs { ImportJob.perform_later(import.id) }

      import.reload
      expect(import.status).to eq("failed")
      expect(import.error_message).to match(/Invalid data/)
      expect(import.result_data).to be_nil
    end
  end
end
