# encoding: utf-8
module Notes
  class NotesRepository
    PRE_PATH =  '/iwinenotes/iwine'

    # return hash
    #
    def self.find(id)
      detail = '/detail/' + id
      path = PRE_PATH + detail
      response =  Notes::NoteAgent.get(:path => path)
      response ? JSON.parse(response.body) : false
    end

    def self.all

    end

    # 他还品鉴了这些酒
    # TODO 加限定返回数量
    def self.find_by_user(user_id, filter_id = '')
      base_url = "/notes/user?uid=#{user_id.to_s}&filterId=#{filter_id}"
      path = PRE_PATH + base_url
      response =  Notes::NoteAgent.get(:path => path)
      response ? JSON.parse(response.body) : false
    end

    # 他们也品鉴了这支酒
    def self.find_by_wine(vintage, name_en, name_zh, note_id, limit = 5)
      base_url = "/notes/guys"
      body = {
          'content' => "#{name_en} #{name_zh}",
          'vintage' => vintage,
          'maxDoc' => limit,
          'filterId' => note_id
      }
      path = PRE_PATH + base_url
      response =  Notes::NoteAgent.post(:path => path, :body => body)
      response ? JSON.parse(response.body) : false
    end
  end
end