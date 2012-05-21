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

    words['wines'][0..3].each do |wine|
      wines.push( Wines::Detail.find( wine['id'] ) );
    end

    words['wineries'][0..1].each do |winery|
      wineries.push( Winery.find( winery['id'] ) );
    end

    { 'wines' => wines , 'wineries' => wineries }
  end

  def all_entries( letters , page , count = 50 )
    words = JSON.parse @http.post( @word_url , 'query=' + letters ).body
    words = JSON.parse @http.post( @word_url , 'query=' + letters ).body
    wines = []
    wineries = []

    start = ( page - 1 ) * count
    endCount = start + count - 1

    words['wines'][start..endCount].each do |wine|
      wines.push( Wines::Detail.find( wine['id'] ) );
    end

    words['wineries'][start..endCount].each do |winery|
      wineries.push( Winery.find( winery['id'] ) );
    end

    { 'wines' => wines , 'wineries' => wineries }
  end
end