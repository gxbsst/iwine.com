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

  namespace :users do
    match ":user_id/" => "users#index"
    match ":user_id/wine_follows" => "users#wine_follows"
    match ":user_id/winery_follows" => "users#winery_follows"
    match ":user_id/comments" => "users#comments"
    match ":user_id/testing_notes" => "users#testing_notes"
    match ":user_id/followings" => "users#followings"
    match ":user_id/followers" => "users#followers"

    ## CELLAR
    match ":user_id/cellars/" => "cellars#index", :via => [:get]
    match ":user_id/cellars/edit" => "cellars#edit"
    ## BID
    match ":user_id/bid/mine" => "bid#mine", :via => [:get]
    match ":user_id/bid/list" => "bid#list"
    ## ALBUMS
    match ":user_id/albums" => "albums#list"
    match ":user_id/albums/list" => "albums#list"
    match ":user_id/albums/show" => "albums#show"
    match ":user_id/albums/photo" => "albums#photo"
    # Syncs
    match "syncs/:type/new" => "syncs#new", :as => :sync_new
    match "syncs/:type/callback" => "syncs#callback", :as => :sync_callback
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
    end
    resources :photos
  end
  
  namespace :mine do
    # 相册
    resources :albums do 
      collection do 
        get "upload"
        post "upload"
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
    resources :wines
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
