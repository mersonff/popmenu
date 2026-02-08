require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe "associations" do
    it { should have_many(:menu_items).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "defaults" do
    it "defaults active to true" do
      menu = Menu.new
      expect(menu.active).to be true
    end
  end

  describe ".active" do
    it "returns only active menus" do
      active_menu = create(:menu, active: true)
      create(:menu, active: false)

      expect(Menu.active).to eq([active_menu])
    end
  end

  describe "dependent destroy" do
    it "destroys associated menu items" do
      menu = create(:menu)
      create(:menu_item, menu: menu)

      expect { menu.destroy }.to change(MenuItem, :count).by(-1)
    end
  end
end
