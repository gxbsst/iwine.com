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

    words['wine'][0..3].each do |wine|
      wines.push( Wines::Detail.find( wine['id'] ) );
    end

    words['winery'][0..1].each do |winery|
      wineries.push( Winery.find( winery['id'] ) );
    end

    { 'wines' => wines , 'wineries' => wineries }
  end

  def all_entries( letters , page = 1 , count = 50 )
    words = JSON.parse @http.post( @word_url , 'query=' + letters ).body
    words = JSON.parse @http.post( @word_url , 'query=' + letters ).body
    wines = []
    wineries = []

    if !page || page < 1
      page = 1
    end

    start = ( page - 1 ) * count
    end_count = start + count - 1

    data = words['wine'][start..end_count]
    if data.present?
      data.each do |wine|
        wines.push( Wines::Detail.find( wine['id'] ) );
      end
    end

    data = words['winery'][start..end_count]
    if data.present?
      data.each do |winery|
        wineries.push( Winery.find( winery['id'] ) );
      end
  end

    { 'wines' => wines , 'wineries' => wineries }
  end
end