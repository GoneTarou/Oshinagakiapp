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
      command.annotate("+0-170", app_title)
      command.pointsize(event_context_pointsize)
      command.annotate("+0-85", event_context)
      command.pointsize(30)
      command.annotate("+0+5", app_title)
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
    Rails.root.join("app/assets/images/okumono.png")
  end

  def font_path
    Rails.root.join("app/assets/fonts/NotoSansJP-VariableFont_wght.ttf")
  end

  def event_context
    return @list.event.name if @list.event_occurrence.blank?

    "#{@list.event.name} #{@list.event_occurrence.number}"
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
    "即売会巡回リスト"
  end

  def featured_space_text
    space_number = featured_space_number || first_space_number
    return if space_number.blank?

    "イチ推し #{space_number}"
  end

  def featured_space_number
    featured_item = ordered_list_items.find do |item|
      item.is_featured? && !item.is_adult_content? && item.space_number.present?
    end

    featured_item&.space_number
  end

  def first_space_number
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
