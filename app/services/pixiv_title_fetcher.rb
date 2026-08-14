require "net/http"
require "nokogiri"
require "uri"

class PixivTitleFetcher
  ALLOWED_HOSTS = %w[pixiv.net www.pixiv.net].freeze
  MAX_HTML_BYTES = 2.megabytes
  MAX_REDIRECTS = 3

  Error = Class.new(StandardError)

  def initialize(source_url)
    @source_url = source_url
  end

  def call
    uri = validate_url(@source_url)
    response = fetch_with_redirects(uri)

    raise Error, "Pixivページを取得できませんでした" unless response.is_a?(Net::HTTPSuccess)
    raise Error, "Pixivページが大きすぎます" if response.body.to_s.bytesize > MAX_HTML_BYTES

    extract_title(Nokogiri::HTML(response.body))
  rescue URI::InvalidURIError, Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    raise Error, e.message
  end

  private

  def fetch_with_redirects(uri, redirects_left = MAX_REDIRECTS)
    response = request(uri)

    return response unless response.is_a?(Net::HTTPRedirection)
    raise Error, "リダイレクト回数が上限を超えました" if redirects_left.zero?

    location = response["location"]
    raise Error, "リダイレクト先がありません" if location.blank?

    redirect_uri = URI.join(uri.to_s, location)
    validate_redirect_url(uri, redirect_uri)

    fetch_with_redirects(redirect_uri, redirects_left - 1)
  end

  def request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 3
    http.read_timeout = 5

    request = Net::HTTP::Get.new(uri.request_uri)
    request["Accept"] = "text/html"
    request["User-Agent"] = "OshinagakiApp/1.0"

    http.request(request)
  end

  def validate_url(value)
    uri = URI.parse(value)

    unless allowed_url?(uri)
      raise Error, "許可されていないPixiv URLです"
    end

    uri
  end

  def validate_redirect_url(current_uri, redirect_uri)
    unless allowed_url?(redirect_uri)
      raise Error, "許可されていないリダイレクト先です"
    end

    if current_uri.scheme == "https" && redirect_uri.scheme != "https"
      raise Error, "安全でないリダイレクトです"
    end
  end

  def allowed_url?(uri)
    %w[http https].include?(uri.scheme) &&
      ALLOWED_HOSTS.include?(uri.host&.downcase) &&
      uri.userinfo.blank?
  end

  def extract_title(document)
    title =
      document.at_css('meta[property="og:title"]')&.[]("content") ||
      document.at_css('meta[name="twitter:title"]')&.[]("content") ||
      document.at_css("title")&.text

    title.to_s.strip.presence || raise(Error, "Pixivタイトルを取得できませんでした")
  end
end
