class ListItem < ApplicationRecord
  belongs_to :list

  validates :space_number, presence: true
  validates :space_number, uniqueness: { scope: :list_id }
end
