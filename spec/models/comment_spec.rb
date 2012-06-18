require 'spec_helper'

describe Comment, "About WineDetail Comment" do
  let(:user) { Factory(:user) }
  # let(:wine_detail) { Factory(:wine_detail)}
  before(:each) do
   @wine_detail = create(:wine_detail)
   @comment = Comment.build_from @wine_detail, user.id, "Comment content" 
  end

  it "comemnts_count should be increment" do
    puts Wines::Detail.find(@wine_detail).comments_count.to_s + "....."
    @comment.do = "comment"
    @comment.save
    puts Wines::Detail.find(@wine_detail).comments_count.to_s + "....."
    Wines::Detail.find(@wine_detail).comments_count.should be(1)
    # expect {
    #   @comment.save
    # }.to change { Wines::Detail.find(@wine_detail).comments_count }.from(0).to(1)
   end

  it " comments_count should be decrement" do
    @comment.do ="comment"
    @comment.save 
    @comment.destroy
    Wines::Detail.find(@wine_detail).comments_count.should be(0)
    # expect {
    #   @comment.destroy
    # }.to change { Wines::Detail.find(@wine_detail).comments_count }.from(1).to(0)
    
  end

  it "followers_count should be increment" do
    @comment.do = "follow"
    @comment.save
    Wines::Detail.find(@wine_detail).followers_count.should be(1)
    # expect {
    #   @comment.save
    # }.to change { Wines::Detail.find(@wine_detail).comments_count }.from(0).to(1)
   end

  it " followers_count should be decrement" do
    @comment.do ="follow"
    @comment.save 
    @comment.destroy
    Wines::Detail.find(@wine_detail).followers_count.should be(0)
    # expect {
    #   @comment.destroy
    # }.to change { Wines::Detail.find(@wine_detail).comments_count }.from(1).to(0)
  end

  it " deleted_at is time now, followers_count should be decrement" do
    @comment.do ="follow"
    @comment.save 
    @comment.deleted_at = Time.now
    @comment.save
    Wines::Detail.find(@wine_detail).followers_count.should be(0)
    # expect {
    #   @comment.destroy
    # }.to change { Wines::Detail.find(@wine_detail).comments_count }.from(1).to(0)
  end

end

describe Comment, "About Winery Comment" do
  let(:user) { Factory(:user) }
  before(:each) do
   @winery = create(:winery)
   @comment = Comment.build_from @winery, user.id, "Comment content" 
  end

  it "comemnts_count should be increment" do
    @comment.do = "comment"
    @comment.save
    Winery.find(@winery).comments_count.should be(1)
    # expect {
    #   @comment_1.save
    # }.to change { Winery.find(@winery).comments_count }.from(0).to(1)
   end

  it " comments_count should be decrement" do
    @comment.do = "comment"
    @comment.save 
    @comment.destroy
    Winery.find(@winery).comments_count.should be(0)
    # expect {
    #   @comment_1.destroy
    # }.to change { Winery.find(@winery).comments_count }.from(1).to(0)
  end

  it "followers_count should be increment" do
    @comment.do = "follow"
    @comment.save

    Winery.find(@winery).followers_count.should be(1)
    # expect {
    #   @comment_1.save
    # }.to change { Winery.find(@winery).comments_count }.from(0).to(1)
   end

  it " followers_count should be decrement" do
    @comment.do = "follow"
    
    @comment.save 
    @comment.destroy
    Winery.find(@winery).followers_count.should be(0)
    # expect {
    #   @comment_1.destroy
    # }.to change { Winery.find(@winery).comments_count }.from(1).to(0)
  end

end
