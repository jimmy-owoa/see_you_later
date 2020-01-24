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
        slug: event.slug,
      }
    end
    render json: data, status: :ok
  end

  # GET /events/{eventname}
  def show
    data = []
    final_data = []
    beauty_dates = []
    user_ids = @event.invitations.pluck(:user_id).uniq
    users = User.where(id: user_ids)
    users.each do |user|
      invitations = []
      @event.invitations.where(user_id: user.id).order(:date).each do |invitation|
        invitations << {
          id: invitation.id,
          user_id: user.id,
          date: invitation.date,
          beauty_date: I18n.l(invitation.date, format: "%-d de %B - %H:%M"),
          accepted: invitation.accepted,
        }
      end
      beauty_dates << invitations.pluck(:beauty_date)
      data << {
        id: user.id,
        name: user.name,
        lastname: user.lastname,
        invitations: invitations,
        total_accepted: invitations.select { |a| a[:accepted] == true }.count,
      }
    end
    final_data << { title: @event.title, data: data, beauty_dates: beauty_dates.uniq.flatten.uniq }
    render json: final_data[0], status: :ok
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    if @event.save
      create_invitations
      render json: @event, status: 200
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
      params[:invitations].each do |user_id|
        params[:dates].each_with_index do |date, i|
          Invitation.create(user_id: user_id, event_id: @event.id, accepted: false, date: date)
        end
      end
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
    @event = Event.find_by(slug: params[:_slug])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Event not found" }, status: :not_found
  end

  def event_params
    params.permit(:title)
  end
end
