require 'spec_helper'

#describe ErrorsController do
  #context 'performance' do
    #before do
      #require 'benchmark'
      #@posts = []
      #@users = []
      #8.times do |n|
        #user = Factory.create(:user)
        #@users << user
        #aspect = user.aspects.create(:name => 'people')
        #connect_users(@user, @aspect0, user, aspect)
        #post =  @user.post(:status_message, :message => "hello#{n}", :to => @aspect1.id)
        #@posts << post
        #8.times do |n|
          #user.comment "yo#{post.message}", :on => post
        #end
      #end
    #end

    #it 'takes time' do
      #Benchmark.realtime{
        #get :index
      #}.should < 1.5
    #end
  #end

  #it "performs reasonably" do
    #require 'benchmark'
    #8.times do |n|
      #aspect = @user.aspects.create(:name => "aspect#{n}")
      #8.times do |o|
        #person = Factory(:person)
        #@user.activate_contact(person, aspect)
      #end
    #end
    #Benchmark.realtime{
      #get :manage
    #}.should < 4.5
  #end
#end

