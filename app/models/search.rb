class Search < ActiveRecord::Base
  def wines
    @wines ||= find_wines
  end

  private

  def find_wines
    wines = Wine.order(:name_en)
    # wines = Wine.includes(:winery,:style, {:details => [:cover]}).where("name_en like ? OR name_zh like ?", "%#{keywords}%", "%#{keywords}%").group(:) if keywords.present?
    # wines = Wines::Detail.includes(:cover, )
    wines = Wines::Detail.includes( :cover, :photos, :statistic,  { :wine => [:style, :winery]} ).where( ["wines.name_en like ? OR wines.name_zh like ?", "%#{keywords}%", "%#{keywords}%"] ).limit(20).group("wine_id")
    
    # wines = Wine.joins(:details => [:cover])
    # wines = Wines.where(category_id: category_id) if category_id.present?
    # wines = Wines.where("price >= ?", min_price) if min_price.present?
    # wines = Wines.where("price <= ?", max_price) if max_price.present?
    wines
  end
end
