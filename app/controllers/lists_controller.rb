class ListsController < ApplicationController
  CREATION_RATE_LIMIT_MESSAGE = <<~MESSAGE.strip.freeze
    短時間に作成できる回数を超えました。
    少し待ってから、もう一度お試しください。
  MESSAGE

  # OGP images and shared lists must also be available to crawlers and older clients.
  allow_browser versions: :modern, except: %i[show ogp_image]
  rate_limit to: 3,
             within: 1.minute,
             only: :create,
             with: :render_creation_rate_limit_error

  def new
    @list = List.new
    @list.list_items.build
    load_events
  end

  def create
    @list = List.new(list_params)

    if @list.save
      redirect_to list_path(token: @list.token)
    else
      load_events
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @list = List.includes(:event).find_by!(token: params[:token])
    @copy_list_items = @list.list_items.order(:created_at, :id).to_a
    @list_items = @copy_list_items.sort_by do |item|
      [ item.is_featured? ? 0 : 1, item.created_at, item.id ]
    end
  end

  def ogp_image
    list = List.includes(:event, :list_items).find_by!(token: params[:token])

    image_data = Rails.cache.fetch(
      [ "ogp-image", OgpImageGenerator::CACHE_VERSION, list.id ],
      expires_in: 1.year
    ) do
      OgpImageGenerator.new(list).call
    end

    expires_in 1.year, public: true, immutable: true

    send_data image_data,
              type: "image/png",
              disposition: "inline"
  rescue MiniMagick::Error, Errno::ENOENT => e
    Rails.logger.error("OGP generation failed (#{e.class}): #{e.message}")
    head :not_found
  end

  def pixiv_title
    list = List.find_by!(token: params[:token])
    item = list.list_items.find(params[:id])

    unless item.pixiv_source?
      render json: { error: "Pixiv URLではありません" }, status: :unprocessable_entity
      return
    end

    title = PixivTitleFetcher.new(item.source_url).call

    render json: { title: title }
  rescue PixivTitleFetcher::Error => e
    Rails.logger.info("Pixiv title fetch failed: #{e.message}")
    render json: { error: "Pixivタイトルを取得できませんでした" }, status: :unprocessable_entity
  end

  private

  def render_creation_rate_limit_error
    flash[:creation_rate_limit_error] = CREATION_RATE_LIMIT_MESSAGE

    redirect_to new_list_path, status: :see_other
  end

  def load_events
    @events = Event.order(:id)
  end

  def list_params
    params.expect(
      list: [
        :event_id,
        { list_items_attributes: [ [
          :space_number,
          :source_url,
          :is_featured,
          :is_adult_content
        ] ] }
      ]
    )
  end
end
