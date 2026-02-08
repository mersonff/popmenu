require 'rails_helper'

RSpec.describe MenuItemPlacement, type: :model do
  describe "associations" do
    it { should belong_to(:menu) }
    it { should belong_to(:menu_item) }
  end

  describe "validations" do
    subject { create(:menu_item_placement) }

    it { should validate_uniqueness_of(:menu_item_id).scoped_to(:menu_id) }
  end
end
