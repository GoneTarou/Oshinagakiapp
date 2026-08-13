class ListItem < ApplicationRecord
  SOURCE_HOSTS = {
    "x" => ["x.com"],
    "pixiv" => ["pixiv.net", "www.pixiv.net"]
  }.freeze

  belongs_to :list

  before_validation :normalize_attributes

  validates :space_number, uniqueness: { scope: :list_id, allow_nil: true }
  validates :source_type, inclusion: { in: SOURCE_HOSTS.keys }, allow_blank: true
  validate :source_url_is_allowed

  private

  def normalize_attributes
    self.space_number = nil if space_number.blank?
    self.source_url = nil if source_url.blank?
    self.source_type = nil if source_url.nil?
  end

  def source_url_is_allowed
    return if source_url.blank?

    if source_type.blank?
      errors.add(:source_type, "を選択してください")
      return
    end

    uri = URI.parse(source_url)

    if !%w[http https].include?(uri.scheme)
      errors.add(:source_url, "はhttpまたはhttpsのURLを入力してください")
    elsif !SOURCE_HOSTS.fetch(source_type).include?(uri.host&.downcase)
      errors.add(:source_url, "は選択したサイトのURLを入力してください")
    end
  rescue URI::InvalidURIError
    errors.add(:source_url, "は正しいURLを入力してください")
  end
end
