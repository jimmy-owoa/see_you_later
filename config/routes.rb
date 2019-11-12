Rails.application.routes.draw do
  resources :users, param: :_phone
  resources :events, param: :_id
  resources :invitations
end
