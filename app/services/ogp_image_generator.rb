require "mini_magick"

class OgpImageGenerator
  WIDTH = 1200
  HEIGHT = 630
  EVENT_CONTEXT_DEFAULT_POINTSIZE = 52
  EVENT_CONTEXT_COMPACT_POINTSIZE = 40
  EVENT_CONTEXT_COMPACT_THRESHOLD = 15

  def initialize(list)
    @list = list
  end

  def call
    image = MiniMagick::Image.open(background_path)

    image.resize("#{WIDTH}x#{HEIGHT}^")
    image.gravity("center")
    image.crop("#{WIDTH}x#{HEIGHT}+0+0")
    image.background("#ffffff")
    image.alpha("remove")
    image.alpha("off")

    image.combine_options do |command|
      command.font(font_path)
      command.fill("#4a2b1a")
      command.gravity("center")
      command.interline_spacing(6)
      command.pointsize(30)
      command.font(app_title_font_path)
      command.annotate("+0-170", app_title)
      command.font(font_path)
      command.pointsize(event_context_pointsize)
      command.annotate("+0-85", event_context)
      command.font(app_title_font_path)
      command.pointsize(30)
      command.annotate("+0+5", app_title)
      command.font(font_path)
      command.pointsize(40)
      command.annotate("+0+85", summary_text)
      command.pointsize(32)
      command.annotate("+0+155", featured_space_text) if featured_space_text.present?
    end

    image.format("png")
    image.to_blob
  end

  private

  def background_path
    Rails.root.join("app/assets/images/pop2.png")
  end

  def font_path
    Rails.root.join("app/assets/fonts/nicomoji-plus_v2-5.ttf")
  end

  def app_title_font_path
    Rails.root.join("app/assets/fonts/nicomoji-plus_v2-5.ttf")
  end

  def event_context
    @list.event.name
  end

  def event_context_pointsize
    if event_context.length > EVENT_CONTEXT_COMPACT_THRESHOLD
      EVENT_CONTEXT_COMPACT_POINTSIZE
    else
      EVENT_CONTEXT_DEFAULT_POINTSIZE
    end
  end

  def summary_text
    "巡回先 #{@list.list_items.size}件"
  end

  def app_title
    "即売会しおり"
  end

  def featured_space_text
    circle_info = featured_circle_info || first_registered_circle_info
    return if circle_info.blank?

    "イチ推し #{circle_info}"
  end

  def featured_circle_info
    featured_item = ordered_list_items.find do |item|
      item.is_featured? && !item.is_adult_content? && item.space_number.present?
    end

    featured_item&.space_number
  end

  def first_registered_circle_info
    first_item = ordered_list_items.find do |item|
      !item.is_adult_content? && item.space_number.present?
    end

    first_item&.space_number
  end

  def ordered_list_items
    @ordered_list_items ||= @list.list_items.sort_by do |item|
      [ item.created_at&.to_f || 0, item.id || 0 ]
    end
  end
end
