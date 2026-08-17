class ListsController < ApplicationController
  # OGP images and shared lists must also be available to crawlers and older clients.
  allow_browser versions: :modern, except: %i[show ogp_image]

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
    @list = List.includes(:event, :list_items).find_by!(token: params[:token])
    @list_items = @list.list_items.order(is_featured: :desc, created_at: :asc, id: :asc)
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
