# -*- coding: utf-8 -*-
Patrick::Application.routes.draw do
  root :to => 'static#index'
  ## ADMIN
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  ## USER
  devise_for :users, :controllers => { :registrations => "registrations" }
  devise_scope :user do
    get :login , :to => "devise/sessions#new"
    get :logout , :to => 'devise/sessions#destroy'
    get :register , :to => 'devise/registrations#new'
  end
  
  # WINE
  resources :wine_details, :controller => "wine_details", :as => :wines, :path => :wines  do
    member do
      # 自定义actions
      get :followers
      get :owners
      get :add_to_cellar
    end 
    
    resources :comments, :controller => "wine_details/comments" do
      member do 
        # 自定义actions
        get :cancle_follow 
        get :vote
        get :reply
        post :reply     
      end
      collection do 
        get :follow
        post :follow
        post :comment
        get :comment
        get :add_to_cellar
      end
    end
    resources :photos, :controller => "wine_details/photos" 
  end
  
  # MINE
  namespace :mine do
    # 相册
    resources :albums do
      # 自定义actions,albums后面不带id 
      collection do 
        get :upload
        post :upload
      end
    end
    # 酒窖
    resources :cellars do
       member do 
         get :add
       end
       resources :cellar_items, :controller => "cellar_items", :path => :items, :as => "items" do
       end
    end
    # 私信
    resources :messages
    resources :conversations
    # 酒
    resources :wines do 
      collection do 
        get :add
      end
    end
  end
  
  # USER
  resources :users do 
    resources :comments
    # 相册
    resources :albums, :controller => "users/albums"
    # 酒窖
    resources :cellars, :controller => "users/cellars" 
  end
  
  # HOME
  resources :home
  # FRIENDS
  # resources :friends
  # oauth china
  match "/friends/:type/sync" => "friends#new", :as => :sync_new
  match "/friends/:type/callback" => "friends#callback", :as => :sync_callback

  # WINERIES
  resources :wineries
  # SETTINGS
  # resources :settings 
  # Search
  resources :searches
  # API
  match ':controller(/:action(/:id))', :controller => /api\/[^\/]+/
  ## STATIC
  match "/about_us", :to => "static#about_us"
  match "/contact_us", :to => "static#contact_us"
  match "/help", :to => "static#help"
  match "/private", :to => "static#private"
  match "/site_map", :to => "static#site_map"
  match "/home", :to => "static#home"

  ## GLOBAL
  match ':controller(/:action(/:id(.:format)))'
  #match ':controller(/:user_id(/:action(.:format)))'
end
