class EventOccurrence < ApplicationRecord
  belongs_to :event

  validates :number, presence: true, numericality: { only_integer: true }
  validates :number, uniqueness: { scope: :event_id }
end
