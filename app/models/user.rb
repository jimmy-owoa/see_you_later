class User < ApplicationRecord
  has_and_belongs_to_many :events
  has_many :invitations, dependent: :destroy
end
