class SettingsController < ApplicationController
  before_filter :authenticate_user!
  def basic
    @user = User.includes(:profile).find(current_user.id)
    @user.profile ||= @user.build_profile
  end

  def privacy
  end

  def invite
  end

  def sync
  end

  def account
  end
end
