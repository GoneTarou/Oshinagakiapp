class EventOccurrence < ApplicationRecord
  belongs_to :event
  has_many :lists, dependent: :restrict_with_error

  validates :number, presence: true, numericality: { only_integer: true }
  validates :number, uniqueness: { scope: :event_id }
end
