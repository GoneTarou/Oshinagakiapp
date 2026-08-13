class ListsController < ApplicationController
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
    @list = List.includes(:event, :event_occurrence, :list_items).find_by!(token: params[:token])
    @list_items = @list.list_items.order(:created_at, :id)
  end

  private

  def load_events
    @events = Event.includes(:event_occurrences).order(:id)
  end

  def list_params
    params.expect(
      list: [
        :event_id,
        :event_occurrence_id,
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
