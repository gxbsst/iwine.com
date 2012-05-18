# -*- coding: utf-8 -*-
Patrick::Application.routes.draw do
  themes_for_rails

  root :to => 'wine_details#index'
  ## ADMIN
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  ## USER
  devise_for :users, :controllers => {  }
  devise_for :users, :controllers => { :sessions => "devise/sessions", :registrations => "devise/registrations" }
  
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
        get :vote
        match "reply", :via => [:get, :post]    
      end
      collection do 
        match "follow", :via => [:get, :post]
        match "comment", :via => [:get, :post]
        get :cancle_follow 
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
        match 'upload_list', :via => [:get, :post]
        match 'save_upload_list', :via => [:get, :post]
        match 'photo_comment', :via => [:get, :post]
      end

      member do
        match 'photo', :via => [:get, :post]
      end
    end
    # 酒窖
    resources :cellars do
       resources :cellar_items, :controller => "cellar_items", :path => :items, :as => "items" do
         collection do
           get :add
         end
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
    member do
      get "wine_follows"
      get "winery_follows"
      get "comments"
      get "followings"
      get "followers"
    end
    resources :comments
    # 相册
    resources :albums, :controller => "users/albums" do
     collection do 
        match 'photo_comment', :via => [:get, :post]
      end 
    end

    
    # 酒窖
    resources :cellars, :controller => "users/cellars" 
  end
  
  # HOME
  resources :home
  # FRIENDS
  # resources :friends do 
  # end
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
