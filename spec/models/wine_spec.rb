# -*- coding: utf-8 -*-
require "spec_helper"
describe Wine do
  describe "#photos_count" do
    # let(:wine_with_photo) { Factory(:wine_with_photo)}
    before(:each) do 
      @wine_with_photo = create(:wine_with_photo)
      @photo = @wine_with_photo.photos.first
      @wine = @photo.imageable # 主要避免find时，不是正确的object
     
    end

    context "When Audit Log items is  Null" do

      it "should increment if photo's audit status change from 0 to 1" do    
        @photo.audit_status = 1
        expect{
            @photo.save
          }.to change{ Wine.find(@wine).photos_count}.from(0).to(1)
      end

      it "should not increment if photo's audit status change from 0 to 2" do
        @photo.audit_status = 2
        @photo.save!
        Wine.find(@wine).photos_count.should be(0)
      end
    end

    context "When Audit Log  items is not Null" do
      context "default audit_status 0" do
        before(:each) do
          create(:audit_log, :result => 0, :owner_type => 5, :business_id => @photo.id)
        end
        it "should increment if photo's audit status change from 0 to 1" do
          @photo.audit_status = 1
          @photo.save!
          Wine.find(@wine).photos_count.should be(1)
        end

        it "should increment if photo's audit status change from 0 to 2" do
          @photo.audit_status = 2
          @photo.save!
          Wine.find(@wine).photos_count.should be(0)
        end

        it "should increment if photo's audit status change from 0 to 0" do
          @photo.audit_status = 0
          @photo.save!
          Wine.find(@wine).photos_count.should be(0)
        end

      end

      context "default audit_status 1" do
        before(:each) do
          create(:audit_log, :result => 1, :owner_type => 5, :business_id => @photo.id)
        end
        it "should increment if photo's audit status change from 1 to 0" do
          @photo.update_attributes(:audit_status => 2)
          # @photo.save!
          Wine.find(@wine).photos_count.should be(0) # 这里应该是0, 因为第一次创建audit logs时， 已经+1, 现在-1 正好等于0
        end
      end
    end
    
  end
end