require 'spec_helper'
describe Wines::Detail do
  # let(:wine_detail) { Factory(:wine_detail)}
  describe "#photos_count" do
    let(:wine_detail_with_photo) { Factory(:wine_detail_with_photo)}
    # before(:each) do 
    #    @wine_detail_with_photo =  Wines::Detail.find(14)
    # end
    context "When Audit Log items is  Null" do

      it "should increment if photo's audit status change from 0 to 1" do
        wine_detail_with_photo.photos.first.audit_status = 1
        wine_detail_with_photo.photos.first.save!
       
        # # wine_detail_with_photo.photos.first.update_attributes(:audit_status => 1)
        # puts ("#{@wine_detail_with_photo.photos.first.counts_should_increment?}")
        Wines::Detail.find(wine_detail_with_photo).photos_count.should be(1)
      end

      it "should not increment if photo's audit status change from 0 to 2" do
        wine_detail_with_photo.photos.first.audit_status = 2
        wine_detail_with_photo.photos.first.save!
        Wines::Detail.find(wine_detail_with_photo).photos_count.should be(0)
      end
    end

    context "When Audit Log  items is not Null" do
      context "default audit_status 0" do
        before(:each) do
          create(:audit_log, :result => 0, :owner_type => 5, :business_id => wine_detail_with_photo.photos.first.id)
        end
        it "should increment if photo's audit status change from 0 to 1" do
          wine_detail_with_photo.photos.first.audit_status = 1
          wine_detail_with_photo.photos.first.save!
          Wines::Detail.find(wine_detail_with_photo).photos_count.should be(1)
        end

        it "should increment if photo's audit status change from 0 to 2" do
          wine_detail_with_photo.photos.first.audit_status = 2
          wine_detail_with_photo.photos.first.save!
          Wines::Detail.find(wine_detail_with_photo).photos_count.should be(0)
        end

        it "should increment if photo's audit status change from 0 to 0" do
          wine_detail_with_photo.photos.first.audit_status = 0
          wine_detail_with_photo.photos.first.save!
          Wines::Detail.find(wine_detail_with_photo).photos_count.should be(0)
        end

      end
      context "default audit_status 1" do
        before(:each) do
          create(:audit_log, :result => 1, :owner_type => 5, :business_id => wine_detail_with_photo.photos.first.id)
        end
        it "should increment if photo's audit status change from 1 to 0" do
          wine_detail_with_photo.photos.first.update_attributes(:audit_status => 2)
          # wine_detail_with_photo.photos.first.save!
          Wines::Detail.find(wine_detail_with_photo).photos_count.should be(0) # 这里应该是0, 因为第一次创建audit logs时， 已经+1, 现在-1 正好等于0
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

end
