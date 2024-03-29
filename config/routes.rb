# frozen_string_literal: true

Rails.application.routes.draw do
  get 'dashboard/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'dashboard#index'
  resources :posts do
    collection do
      get :search
    end
  end
end
