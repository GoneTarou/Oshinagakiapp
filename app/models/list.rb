class List < ApplicationRecord
  belongs_to :event
  has_many :list_items, dependent: :restrict_with_error
  accepts_nested_attributes_for :list_items, reject_if: :reject_blank_list_item

  before_validation :generate_token, on: :create

  validates :token, presence: true, uniqueness: true
  validate :has_at_least_one_item
  validate :has_at_most_twenty_items
  validate :has_at_most_one_featured_item

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def has_at_most_twenty_items
    return if list_items.size <= 20

    errors.add(:list_items, "は20件以内で登録してください")
  end

  def has_at_least_one_item
    errors.add(:base, "巡回先を1件以上登録してください") if list_items.empty?
  end

  def has_at_most_one_featured_item
    return if list_items.count(&:is_featured?) <= 1

    errors.add(:list_items, "イチ推しは1件まで登録できます")
  end

  def reject_blank_list_item(attributes)
    attributes["space_number"].blank? && attributes["source_url"].blank?
  end
end
