Rails.application.routes.draw do
  get 'api/execute'
  root 'home#index'
end
