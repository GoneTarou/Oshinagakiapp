require "mini_magick"

class OgpImageGenerator
  WIDTH = 1200
  HEIGHT = 630

  def initialize(list)
    @list = list
  end

  def call
    image = MiniMagick::Image.open(background_path)

    image.resize("#{WIDTH}x#{HEIGHT}^")
    image.gravity("center")
    image.crop("#{WIDTH}x#{HEIGHT}+0+0")

    image.combine_options do |command|
      command.font(font_path)
      command.fill("#4a2b1a")
      command.gravity("center")
      command.interline_spacing(8)
      command.pointsize(52)
      command.annotate("+0-50", event_context)
      command.pointsize(34)
      command.annotate("+0+35", summary_text)
    end

    image.format("png")
    image.to_blob
  end

  private

  def background_path
    Rails.root.join("app/assets/images/okumono.png")
  end

  def font_path
    Rails.root.join("app/assets/fonts/NotoSansJP-VariableFont_wght.ttf")
  end

  def event_context
    return @list.event.name if @list.event_occurrence.blank?

    "#{@list.event.name} #{@list.event_occurrence.number}"
  end

  def summary_text
    summary = "巡回先 #{@list.list_items.size}件"
    featured_item = @list.list_items.find do |item|
      item.is_featured? && !item.is_adult_content? && item.space_number.present?
    end

    if featured_item
      summary += "　👑 イチ推し #{featured_item.space_number}"
    end

    summary
  end
end
