require 'spec_helper'
describe Wines::Detail do
  # let(:wine_detail) { Factory(:wine_detail)}
  describe "#photos_count" do
    # let(:wine_detail_with_photo) { Factory(:wine_detail_with_photo)}
    before(:each) do 
      @wine_detail_with_photo = create(:wine_detail_with_photo)
      @photo = @wine_detail_with_photo.photos.first
      @wine_detail = @photo.imageable # 主要避免find时，不是正确的object
    end

    context "When Audit Log items is  Null" do

      it "should increment if photo's audit status change from 0 to 1" do    
        @photo.audit_status = 1
        expect{
            @photo.save
          }.to change{ Wines::Detail.find(@wine_detail).photos_count}.from(0).to(1)
      end

      it "should not increment if photo's audit status change from 0 to 2" do
        @photo.audit_status = 2
        @photo.save!
        Wines::Detail.find(@wine_detail).photos_count.should be(0)
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
          Wines::Detail.find(@wine_detail).photos_count.should be(1)
        end

        it "should increment if photo's audit status change from 0 to 2" do
          @photo.audit_status = 2
          @photo.save!
          Wines::Detail.find(@wine_detail).photos_count.should be(0)
        end

        it "should increment if photo's audit status change from 0 to 0" do
          @photo.audit_status = 0
          @photo.save!
          Wines::Detail.find(@wine_detail).photos_count.should be(0)
        end

      end

      context "default audit_status 1" do
        before(:each) do
          create(:audit_log, :result => 1, :owner_type => 5, :business_id => @photo.id)
        end
        it "should increment if photo's audit status change from 1 to 0" do
          @photo.update_attributes(:audit_status => 2)
          # @photo.save!
          Wines::Detail.find(@wine_detail).photos_count.should be(0) # 这里应该是0, 因为第一次创建audit logs时， 已经+1, 现在-1 正好等于0
        end
      end
    end

  end

  describe  "#owners_count" do
    let(:wine_detail) { Factory(:wine_detail)}
    it "should increment if cellar item is created" do
      @wine_cellar_item = build(:wine_cellar_item, :wine_detail_id => wine_detail.id)
      @wine_cellar_item.save
      Wines::Detail.find(wine_detail).owners_count.should be(1)
    end

    it "should decrement if cellar item is destroy" do
      @wine_cellar_item = build(:wine_cellar_item)
      @wine_cellar_item.save
      @wine_detail = @wine_cellar_item.wine_detail
      @wine_cellar_item.destroy
      Wines::Detail.find(@wine_detail).owners_count.should be(0)
    end
  end

  describe  "#followers_count" do 
    before(:each) do
      @follow = create(:follow)
    end
    it "followers_count should be increment" do
      Wines::Detail.find(@follow.followable).followers_count.should be(1)
      # expect {
      #   @comment.save
      # }.to change { Wines::Detail.find(@wine_detail).comments_count }.from(0).to(1)
     end

    it " followers_count should be decrement" do
      @follow.destroy
      Wines::Detail.find(@follow.followable).followers_count.should be(0)
    end
  end

end
