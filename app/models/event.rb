# app/models/event.rb
class Event < ApplicationRecord
  has_many :event_occurrences, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
