require 'net/http'

class HotSearch

  def initialize
    server = APP_DATA['search_server']
    @entry_url = server['entry_url']
    @word_url = server['word_url']
    @user_url = server['user_url']
    @event_url = server['event_url']
    @wine_url = server['wine_url']
    @winery_url = server['winery_url']
    @http = Net::HTTP.start( server['host'] , server['port'] )
  end

  def hot_words(letters)
    words = JSON.parse @http.post( @word_url , 'query=' + letters ).body
    wine_details = find_wine_details(words['wine'][0..3])
    wineries = find_wineries(words['winery'][0..1])
    { 'wines' => wine_details , 'wineries' => wineries }
  end

  def all_entries(letters)
    words = JSON.parse @http.post( @entry_url , 'query=' + letters ).body
    wines = find_wines(words['wine'])
    wineries = find_wineries(words['winery'])
    { 'wines' => wines , 'wineries' => wineries}
  end

  def search_user(word)
    words = JSON.parse @http.post(@user_url, "query=#{word}").body
    user_ids = get_ids(words['users'])
    users = User.order("followers_count desc").find(user_ids) if user_ids.present?
  end

  # 搜索活动
  def search_event(word)
    words = JSON.parse @http.post(@event_url, "query=#{word}").body
    events = Event.order('created_at DESC').find(words['events']) unless words['events'].blank?
  end

  # 搜索酒
  def search_wine(word)
    words = JSON.parse @http.post(@wine_url, "query=#{word}").body
    wines = find_wines(words['wine'])
  end

  # 搜索酒庄
  def search_winery(word)
    words = JSON.parse @http.post(@winery_url, "query=#{word}").body
    wineries = find_wineries(words['winery'])
  end
  
  def find_wine_details(ids)
    wine_detail_ids = get_ids(ids)
    Wines::Detail.find(wine_detail_ids, 
                  :order => "field(id, #{wine_detail_ids.join(',')})") if wine_detail_ids.present?
  end

  def find_wines(ids)
    wine_ids = get_ids(ids)
    Wine.find(wine_ids, :order => "field(id, #{wine_ids.join(',')})") if wine_ids.present?
  end

  def find_wineries(ids)
    winery_ids = get_ids(ids)
    Winery.find(winery_ids, :order => "field(id, #{winery_ids.join(',')})") if winery_ids.present?
  end

  #从搜到的数据获得wine_ids或winery_ids
  def get_ids(objects)
    objects.inject([]){|memo, obj| memo << obj['id']}.compact
  end
end