require 'sidekiq/web'

Rails.application.routes.draw do
  resources :accounts
  %w[assets equities revenues revenues liabilities expenses].each do |type|
    resources "account_#{type}", controller: :accounts, path: :accounts
  end
  resources :events, only: :index

  mount Leather::Engine => '/'
  mount Sidekiq::Web, at: '/sidekiq'
end
