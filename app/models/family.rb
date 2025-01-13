class Family < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_one_attached :photo

  validates :name, presence: true
  searchable do
    text :name
  end
end

