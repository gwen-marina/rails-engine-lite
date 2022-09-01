class Merchant < ApplicationRecord
  has_many :items

  validates_presence_of :name

  def self.find_by_name(search)
    merchant = Merchant.find_by('name ILIKE ?', "%#{search}%")
  end
end
