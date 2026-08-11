class List < ApplicationRecord
  belongs_to :event
  belongs_to :event_occurrence, optional: true
  has_many :list_items, dependent: :restrict_with_error

  before_validation :generate_token, on: :create

  validates :token, presence: true, uniqueness: true
  validate :event_occurrence_requirement
  validate :has_at_most_twenty_items
  validate :has_at_most_one_featured_item

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def event_occurrence_requirement
    return if event.blank?

    if event.name == "その他" && event_occurrence_id.present?
      errors.add(:event_occurrence, "その他では開催回を指定できません")
    elsif event.name != "その他" && event_occurrence_id.blank?
      errors.add(:event_occurrence, "開催回を選択してください")
    end
  end

  def has_at_most_twenty_items
    return if list_items.size <= 20

    errors.add(:list_items, "は20件以内で登録してください")
  end

  def has_at_most_one_featured_item
    return if list_items.count(&:is_featured?) <= 1

    errors.add(:list_items, "イチ推しは1件まで登録できます")
  end
end
