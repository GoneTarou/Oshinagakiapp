class ListItem < ApplicationRecord
  belongs_to :list

  before_validation :normalize_space_number

  validates :space_number, uniqueness: { scope: :list_id, allow_nil: true }

  private

  def normalize_space_number
    self.space_number = nil if space_number.blank?
  end
end
