class EventsController < ApplicationController
  before_action :find_event, except: %i[create index]

  # GET /events
  def index
    @events = Event.all
    render json: @events, status: :ok
  end

  # GET /events/{eventname}
  def show
    data = { event: @event,
            users: @event.users }
    render json: data, status: :ok
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    if @event.save
      render json: @event, status: :created
    else
      render json: { errors: @event.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # PUT /events/{eventname}
  def update
    unless @event.update(event_params)
      render json: { errors: @event.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /events/{eventname}
  def destroy
    @event.destroy
  end

  private

  def find_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Event not found" }, status: :not_found
  end

  def event_params
    params.permit(:title, :date)
  end
end
