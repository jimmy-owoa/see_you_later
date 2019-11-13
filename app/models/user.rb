class User < ApplicationRecord
  has_and_belongs_to_many :events
  has_many :users, dependent: :delete_all
end
