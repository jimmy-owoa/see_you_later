class EventsController < ApplicationController
  before_action :sanitize_date_params, except: %i[show index destroy]
  before_action :find_event, except: %i[create index]

  # GET /events
  def index
    @events = Event.all
    render json: @events, status: :ok
  end

  # GET /events/{eventname}
  def show
    invitations = []
    @event.invitations.each do |invitation|
      user = invitation.user
      invitations << {
        id: invitation.id,
        name: user.name,
        lastname: user.lastname,
        accepted: invitation.accepted ? "Aceptado" : "Pendiente",
        phone: user.phone,
      }
    end
    data = { event: @event,
             invitations: invitations }
    render json: data, status: :ok
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    binding.pry
    if @event.save
      create_invitations
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
    render json: { status: :deleted } if @event.destroy
  end

  private

  def create_invitations
    if params[:invitations].present?
      params[:invitations].each do |user_id| Invitation.create(user_id: user_id, event_id: @event.id, accepted: false) end
    end
  end

  def sanitize_date_params
    params[:date] = params[:date].to_datetime
  end

  def find_event
    @event = Event.find(params[:_id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Event not found" }, status: :not_found
  end

  def event_params
    params.permit(:title, :date)
  end
end
