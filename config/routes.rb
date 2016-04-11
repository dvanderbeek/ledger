require 'sidekiq/web'

Rails.application.routes.draw do
  resources :accounts
  resources :account_assets, controller: :accounts, path: :accounts
  resources :account_equities, controller: :accounts, path: :accounts
  resources :account_revenues, controller: :accounts, path: :accounts
  resources :account_liabilities, controller: :accounts, path: :accounts
  resources :account_expenses, controller: :accounts, path: :accounts

  mount Leather::Engine => '/'
  mount Sidekiq::Web, at: '/sidekiq'
end
