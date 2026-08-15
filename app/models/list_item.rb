class ListItem < ApplicationRecord
  ALLOWED_SOURCE_HOSTS = %w[x.com pixiv.net www.pixiv.net].freeze

  belongs_to :list

  before_validation :normalize_attributes

  validates :space_number, uniqueness: { scope: :list_id, allow_nil: true }
  validate :source_url_is_allowed

  def pixiv_source?
    uri = URI.parse(source_url.to_s)

    %w[pixiv.net www.pixiv.net].include?(uri.host&.downcase)
  rescue URI::InvalidURIError
    false
  end

  private

  def normalize_attributes
    self.space_number = nil if space_number.blank?
    self.source_url = nil if source_url.blank?
  end

  def source_url_is_allowed
    return if source_url.blank?

    uri = URI.parse(source_url)

    if !%w[http https].include?(uri.scheme)
      errors.add(:source_url, "はhttpまたはhttpsのURLを入力してください")
    elsif !ALLOWED_SOURCE_HOSTS.include?(uri.host&.downcase)
      errors.add(:source_url, "はXまたはpixivのURLを入力してください")
    elsif uri.host&.downcase == "x.com" && !x_post_url?(uri)
      errors.add(:source_url, "はXの投稿URLを入力してください")
    end
  rescue URI::InvalidURIError
    errors.add(:source_url, "は正しいURLを入力してください")
  end

  def x_post_url?(uri)
    uri.path.match?(%r{\A/[^/]+/status/\d+/?\z})
  end
end
