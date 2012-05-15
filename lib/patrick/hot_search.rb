require 'net/http'

class HotSearch

  def initialize
    server = APP_DATA['search_server']
    @entry_url = server['entry_url']
    @word_url = server['word_url']
    @http = Net::HTTP.start( server['host'] , server['port'] )
  end

  def hot_words( letters )
    JSON.parse @http.post( @word_url , 'query=' + letters ).body
  end

  def hot_entries( words )
    JSON.parse @http.post( @entry_url + 'all' , 'query=' + words ).body
  end

end