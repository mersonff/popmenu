require 'rails_helper'

RSpec.describe Import, type: :model do
  describe "validations" do
    it { is_expected.to validate_inclusion_of(:status).in_array(Import::STATUSES) }
    it { is_expected.to validate_presence_of(:input_data) }
  end

  describe "defaults" do
    it "defaults status to pending" do
      import = Import.new(input_data: { "restaurants" => [] })
      expect(import.status).to eq("pending")
    end
  end

  describe "predicates" do
    let(:import) { Import.new(input_data: { "restaurants" => [] }) }

    it "#pending?" do
      import.status = "pending"
      expect(import).to be_pending
    end

    it "#processing?" do
      import.status = "processing"
      expect(import).to be_processing
    end

    it "#completed?" do
      import.status = "completed"
      expect(import).to be_completed
    end

    it "#failed?" do
      import.status = "failed"
      expect(import).to be_failed
    end

    it "#finished? returns true for completed" do
      import.status = "completed"
      expect(import).to be_finished
    end

    it "#finished? returns true for failed" do
      import.status = "failed"
      expect(import).to be_finished
    end

    it "#finished? returns false for pending" do
      import.status = "pending"
      expect(import).not_to be_finished
    end
  end
end
