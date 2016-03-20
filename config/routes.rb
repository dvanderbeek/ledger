require 'sidekiq/web'

Rails.application.routes.draw do
  mount Leather::Engine => '/'
  mount Sidekiq::Web, at: '/sidekiq'
end
