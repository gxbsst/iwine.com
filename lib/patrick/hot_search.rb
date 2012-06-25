require 'net/http'

class HotSearch

  def initialize
    server = APP_DATA['search_server']
    @entry_url = server['entry_url']
    @word_url = server['word_url']
    @http = Net::HTTP.start( server['host'] , server['port'] )
  end

  def hot_words( letters )
    words = JSON.parse @http.post( @word_url , 'query=' + letters ).body
    
    wine_detail_ids = get_ids(words['wine'][0..3])
    wine_details = Wines::Detail.find(wine_detail_ids)

    winery_ids = get_ids(words['winery'][0..1])
    wineries = Winery.find(winery_ids)

    { 'wines' => wine_details , 'wineries' => wineries }
  end

  def all_entries(letters)
    words = JSON.parse @http.post( @entry_url , 'query=' + letters ).body

    wine_ids = get_ids(words['wine'])
    wines = Wine.find(wine_ids) if wine_ids.present?

    winery_ids = get_ids(words['winery'])
    wineries = Winery.find(winery_ids) if winery_ids.present?

    { 'wines' => wines , 'wineries' => wineries}
  end
  
  #从搜到的数据获得wine_ids或winery_ids
  def get_ids(objects)
    objects.inject([]){|memo, obj| memo << obj['id']}.compact
  end
end