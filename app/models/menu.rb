class Menu < ApplicationRecord
  belongs_to :restaurant
  has_many :menu_item_placements, dependent: :destroy
  has_many :menu_items, through: :menu_item_placements

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
