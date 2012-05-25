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
  
  # COMMENT
  resources :comments do 
    member do 
       match "reply", :via => [:get, :post]
       get :vote
    end
  end
  
  # WINE
  resources :wine_details, :controller => "wine_details", :as => :wines, :path => :wines  do
    member do
      # 自定义actions
      get :followers
      get :owners
      get :add_to_cellar
    end 
    resources :comments, :controller => "comments" do
      member do
        get :vote
        match "reply", :via => [:get, :post]
      end
      collection do
        get :cancle_follow 
      end
    end    
    resources :photos
  end
  
  # PHOTO
  resources :photos do
    resources :comments, :as => "photo_comments"
    member do
      get "vote"
    end
  end
  # 相册
   resources :albums do
     # 自定义actions,albums后面不带id 
     collection do 
       match "upload", :via => [:get, :post]
       match 'upload_list', :via => [:get, :post]
       match 'save_upload_list', :via => [:get, :post]
       match 'photo_comment', :via => [:get, :post]
       match 'delete_photo', :via => [:get, :post]
       match 'update_photo_intro', :via => [:put]
     end
     member do
       get "vote"
       match 'delete', :via => [:post, :get]
     end
   end
  
  # USER
  resources :users do 
    member do 
      match "wine_follows", :via => [:get]
      match "winery_follows", :via => [:get]
      match "comments", :via => [:get]
      match "followings", :via => [:get]
      match "followers", :via => [:get]
      # Album
      match "albums", :via => [:get], :to => "albums#index"
      match "albums/:album_id", :via => [:get], :to => "albums#show"
      match "albums/:album_id/photo/:photo_id", :via => [:get], :to => "albums#photo"
    end
    collection do
      get "register_success"
    end

     # 酒窖
     resources :cellars, :controller => "users/cellars" do
        resources :cellar_items, :controller => "users/cellar_items", :path => :items, :as => "items" do
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
  
  # HOME
  resources :home
  # FRIENDS
  # resources :friends do 
  # end
  # oauth china
  match "/friends/:type/sync" => "friends#new", :as => :sync_new
  match "/friends/:type/callback" => "friends#callback", :as => :sync_callback

  # WINERIES
  resources :wineries do
    member do
      get "wines_list"
      get "followers_list"
    end
    resources :photos
    resources :comments, :controller => "comments" do
      member do
        get :vote
        match "reply", :via => [:get, :post]
      end
      collection do
        get :cancle_follow
      end
    end
  end
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
  resources :searches do
    collection do
      get :winery, :via => [:get , :put]
      get :suggestion, :via => [:get , :put]
      get :results, :via => [:get , :put]
    end
  end


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
