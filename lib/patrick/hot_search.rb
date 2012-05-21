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
    wines = []
    wineries = []

    words['wines'][0..4].each do |wine|
      wines.push( {
        'id' => wine['id'],
        'name' => wine['name'],
        'pic' => Wines::Detail.find( wine['id'] ).cover
      });
    end

    words['wineries'][0..3].each do |winery|
      wineries.push( {
        'id' => wine['id'],
        'name' => wine['name'],
        'pic' => Winery.find( winery['id'] ).log
      });
    end

    { 'wines' => wines , 'wineries' => wineries }
  end

  def hot_entries( words )
    JSON.parse @http.post( @entry_url + 'all' , 'query=' + words ).body
  end
end