class EventsController < ApplicationController
  before_action :sanitize_date_params, except: %i[show index destroy]
  before_action :find_event, except: %i[create index]

  # GET /events
  def index
    @events = Event.all
    data = []
    @events.each do |event|
      data << {
        id: event.id,
        title: event.title,
        date: event.date.strftime("%d/%m/%Y · %H:%M"),
      }
    end
    render json: data, status: :ok
  end

  # GET /events/{eventname}
  def show
    invitations = []
    accepted = 0
    @event.invitations.each do |invitation|
      user = invitation.user
      accepted += 1 if invitation.accepted
      invitations << {
        id: invitation.id,
        name: user.name,
        lastname: user.lastname,
        accepted: invitation.accepted,
        status: invitation.accepted,
        phone: user.phone,
      }
    end
    data = { event: @event,
             invitations: invitations,
             accepted_users: accepted }
    render json: data, status: :ok
  end

  # POST /events
  def create
    params[:dates].each do |date|
      @event = Event.new(title: params[:title], date: date)
      if @event.save
        create_invitations
      else
        render json: { errors: @event.errors.full_messages },
               status: :unprocessable_entity
      end
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
    dates = []
    params[:dates].each do |date|
      dates << date.to_datetime
    end
    params[:dates] = dates
  end

  def find_event
    @event = Event.find(params[:_id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Event not found" }, status: :not_found
  end

  def event_params
    params.permit(:title, :dates)
  end
end
