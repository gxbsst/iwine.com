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
        match "reply", :via => [:get, :post]    
      end
      collection do 
        match "follow", :via => [:get, :post]
        match "comment", :via => [:get, :post]
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
        match "upload", :via => [:get, :post]
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
    collection do
      get "register_success"
    end
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
  resources :settings do
    collection do
      match :basic, :via => [:get, :put]
      match :privacy, :via => [:get, :put]
      match :avatar, :via => [:get, :post, :put]
      get :sync
      get :syncs
      match :update_password, :via => [:get, :put]
    end
  end
  # Search
  resources :searches
  # API
  match ':controller(/:action(/:id))', :controller => /api\/[^\/]+/
  ## STATIC
  statics = %w(about_us contact_us help private site_map home)
  statics.each do |i|
     match "/#{i}", :to => "static##{i}"
  end

  ## GLOBAL
  match ':controller(/:action(/:id(.:format)))'
  #match ':controller(/:user_id(/:action(.:format)))'
end
