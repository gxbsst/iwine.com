# -*- coding: utf-8 -*-
Patrick::Application.routes.draw do
 
  resources :after_first_signins do
    collection do
      match :upload_avatar, :via => [:get, :post, :put]
    end
  end


  #first login iWine
  resources :oauth_logins

  resources :follows
  resources :oauth_logins do
    collection do 
      get :sns_login
      get :update_info
    end
  end
  themes_for_rails

  # unless Rails.application.config.consider_all_requests_local
  #    match '*not_found', to: 'errors#error_404'
  # end

  root :to => 'static#index'
  ## ADMIN
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  ## USER
  devise_for :users, :controllers => { :sessions => "sessions",
                                       :registrations => "registrations",
                                       :omniauth_callbacks => "omniauth_callbacks"}
  

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
       get :children
    end
  end
  resources :friends do
    collection do
      get :find
      get :sync
      get :sns
      get :new_sns
      get :setting_sns
      get :delete_sns
      get :search
    end
    member do
      post :email_invite
    end
  end
  # WINE
  resources :wine_details, :controller => "wine_details", :as => :wines, :path => :wines  do
    member do
      # 自定义actions
      get :followers
      get :owners
      get :add_to_cellar
      get :photo_upload
    end
    collection do
      get :add
    end
    resources :comments, :controller => "comments" do
      member do
        get :vote
        match "reply", :via => [:get, :post]
      end
      collection do
        get :cancle_follow 
        post :create, :as => "wines_detail" # 这里主要是为了使评论表单的URL为一致
      end
    end    
    resources :photos
    resources :follows, :controller => "follows" 
  end
  
  # PHOTO
  resources :photos do
    resources :comments#, :as => "photo_comments"
    # resources :comments, :controller => "comments"
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
       match 'edit', :via => [:put, :get]
     end
   end
  
  # USER
  resources :users do 
    member do 
      match "wine_follows", :via => [:get]
      match "winery_follows", :via => [:get]
      match "comments", :via => [:get]
      match "followings", :via => [:get]
      match "start", :via => [:get, :post]
      match "followers", :via => [:get]
      # Album
      match "albums", :via => [:get], :to => "albums#index"
      match "albums/:album_id", :via => [:get], :to => "albums#show", :as => :album_show
      match "albums/:album_id/photo/:photo_id", :via => [:get], :to => "albums#photo", :as => :album_photo_show
      # Cellars
      match "cellars/:cellar_id", :via => [:get], :to => "cellars#show", :as => :cellars
      get :follow
      get :unfollow
    end
    collection do
      get "register_success"
    end
  end
  
  # 酒窖
  resources :cellars do
     resources :cellar_items, :path => :items, :as => "items" do
       collection do
         get :add
       end
     end
  end
  
  # 私信
  resources :messages do 
    collection do
      get :unread
    end
  end
  resources :conversations
  
  # HOME
  resources :home
  # FRIENDS
  # resources :friends do 
  # end
  # oauth china


  match "/friends/:type/sync" => "friends#new", :as => :sync_new
  match "/friends/:type/callback" => "friends#callback", :as => :sync_callback

  match "oauth_logins/:type/sns_login" => "oauth_logins#sns_login" 
  match "oauth_logins/:type/update_info" => "oauth_logins#update_info"
  

  # WINERIES
  resources :wineries do
    member do
      get "wines_list"
      get "followers_list"
      get "photo_upload"
    end
    resources :photos
    resources :comments, :controller => "comments" do
      member do
        get :vote
        match "reply", :via => [:get, :post]
      end
      collection do
        get :cancle_follow
        post :create, :as => "winery" # 这里主要是为了使评论表单的URL为一致
      end
    end
    resources :follows, :controller => "follows" 
  end
  # SETTINGS
  resources :settings do
    collection do
      match :basic, :via => [:get, :put]
      match :privacy, :via => [:get, :put]
      match :avatar, :via => [:get, :post, :put]
      match :domain, :via => [:get, :put]
      get :sync
      get :syncs
      match :update_password, :via => [:get, :put]
      put :update
    end
  end
  # Search
  resources :searches do
    collection do
      get :winery, :via => [:get , :put]
      get :suggestion, :via => [:get , :put]
      get :results, :via => [:get , :put]
      post :search_user
    end
  end


  # API
  namespace :api do
    api_version(:module => "v1", :header => "Accept", :value => "application/vnd.iwine.com; version=1") do
      resources :registrations
      resources :sessions
      resources :uploads
      resources :profiles
      resources :oauths
    end
   end
  match ':controller(/:action(/:id))', :controller => /api\/[^\/]+/

  # STATIC
  statics = %w(about_us contact_us help private agreement terms_and_conditions site_map home feedback)
  statics.each do |i|
     match "/#{i}", :to => "static##{i}"
  end

  # Feedback
  resources :feedbacks do 
    collection do
      get "success"
    end
  end

  ## GLOBAL
  match ':controller(/:action(/:id(.:format)))'
  #match ':controller(/:user_id(/:action(.:format)))'
end
