class InvitationsController < ApplicationController
  before_action :find_invitation, except: %i[create index]

  # GET /invitations
  def index
    @invitations = Invitation.all
    render json: @invitations, status: :ok
  end

  def change_response
    @invitation.update(accepted: !@invitation.accepted)
    render json: { message: "Estado cambiado" }, status: 200
  end

  # GET /invitations/{invitationname}
  def show
    data = { invitation: @invitation,
            user: @invitation.user,
            event: @invitation.event }
    render json: data, status: :ok
  end

  # POST /invitations
  def create
    @invitation = Invitation.new(invitation_params)
    if @invitation.save
      render json: @invitation, status: :created
    else
      render json: { errors: @invitation.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # PUT /invitations/{invitationname}
  def update
    unless @invitation.update(invitation_params)
      render json: { errors: @invitation.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /invitations/{invitationname}
  def destroy
    @invitation.destroy
  end

  private

  def find_invitation
    @invitation = Invitation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Invitation not found" }, status: :not_found
  end

  def invitation_params
    params.permit(:user_id, :event_id, :accepted)
  end
end
