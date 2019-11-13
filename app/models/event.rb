class Event < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :invitations, dependent: :delete_all
end
