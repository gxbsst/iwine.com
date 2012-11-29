# encoding: utf-8
module Notes
  class NotesRepository
    PRE_PATH =  '/iwinenotes/iwine'

    # return hash
    #
    def self.find(id)
      detail = "/detail/#{id}"
      path = PRE_PATH + detail
      response =  Notes::NoteAgent.get(:path => path)
      response ? JSON.parse(response.body) : false
    end

    def self.all(modified_date = "")
      if modified_date.blank?
        hot = '/hot'
      else
        hot = "/hot?modifiedDate=#{modified_date}"
      end
      path = PRE_PATH + URI::escape(hot)
      response =  Notes::NoteAgent.get(:path => path)
      response ? JSON.parse(response.body) : false
    end 

    #一支酒的所有评酒辞
    def self.find_wine_notes(wine_detail_id) 
      detail = "/notes/detail/#{wine_detail_id}"
      path = PRE_PATH + detail
      response =  Notes::NoteAgent.get(:path => path)
      response ? JSON.parse(response.body) : false
    end

    # 他还品鉴了这些酒
    # TODO 加限定返回数量
    def self.find_by_user(user_id, filter_id = '')
      base_url = "/notes/user?uid=#{user_id.to_s}&filterId=#{filter_id}&maxDoc=5"
      path = PRE_PATH + base_url
      response =  Notes::NoteAgent.get(:path => path)
      response ? JSON.parse(response.body) : false
    end

    # 他们也品鉴了这支酒
    def self.find_by_wine(vintage, name_en, name_zh, note_id, limit = 5, filter_id ="")
      base_url = "/notes/guys"
      body = {
          'content' => "#{name_en} #{name_zh}",
          'vintage' => vintage,
          'maxDoc' => limit,
          'filterId' => note_id,
          'minScore' => 0.9 # 根据匹配度返回值
      }
      path = PRE_PATH + base_url
      response =  Notes::NoteAgent.post(:path => path, :body => body)
      response ? JSON.parse(response.body) : false
    end

    def self.delete_note(note)
      base_url = "/push"
      body = {"id" => note.app_note_id.to_s, 
        "wine.vintage" => note.is_nv ? "NV" : note.vintage.try(:to_s),
        "wine.style" => note.wine_style_id.try(:to_s),
        "wine.sName" => note.name,
        "agent" => NOTE_DATA['note']['user_agent']['local'],
        "deleteFlag" => note.delete_flag}
      path = "#{PRE_PATH}#{base_url}"
      response =  Notes::NoteAgent.post(:path => path, :body => body)
      response ? JSON.parse(response.body) : false
    end

    def self.post_note(note)
      base_url = "/push"
      body = {
        "id" => note.app_note_id.try(:to_s),
        "notesId" => note.uuid,
        "location.location" => note.location,
        "createdDate" => note.created_at.to_s(:app_time),
        "modifiedDate" => note.modifiedDate.to_s(:app_time),
        "deleteFlag" => "#{note.delete_flag.to_i}",
        "syncFlag" => note.sync_flag,
        "statusFlag" => "#{note.status_flag.to_i}",
        "agent" => NOTE_DATA['note']['user_agent']['local'],
        "uid" => note.user_id.try(:to_s),
        "covers[0].image" => note.byte_array_image,
        "wine.detail" => note.wine_detail_id.try(:to_s),
        "wine.sName" => note.name,
        "wine.oName" => note.other_name,
        "wine.region" => note.region_tree_id.try(:to_s),
        "wine.vintage" => note.is_nv ? "NV" : note.vintage.try(:to_s),
        "wine.style" => note.wine_style_id.try(:to_s),
        "wine.alcohol" => note.alcohol.to_f.to_s,
        "wine.price" => note.price.try(:to_s),
        "wine.comment" => note.comment,
        "wine.rating" => (note.rating.to_i - 1).to_s,
        "wine.currency" => note.exchange_rate.name_en,
        "wine.variety" => note.upload_variety_percentage,
        "notesAdvance.appearanceClarity" => note.appearance_clarity,
        "notesAdvance.appearanceIntensity" => note.appearance_intensity,
        "notesAdvance.appearanceColor" => note.appearance_color,
        "notesAdvance.appearanceOther" => note.appearance_other,
        "notesAdvance.noseCondition" => note.nose_condition,
        "notesAdvance.noseIntensity" => note.nose_intensity,
        "notesAdvance.noseDevelopment" => note.nose_development,
        "notesAdvance.noseAroma" => note.nose_aroma,
        "notesAdvance.palateSweetness" => note.palate_sweetness,
        "notesAdvance.palateAcidity" => note.palate_acidity,
        "notesAdvance.palateAlcohol" => note.palate_alcohol,
        "notesAdvance.palateTanninLevel" => note.palate_tannin_level,
        "notesAdvance.palateTanninNature" => note.palate_tannin_nature, 
        "notesAdvance.palateBody" => note.palate_body,
        "notesAdvance.palateFlavorIntensity" => note.palate_flavor_intensity,
        "notesAdvance.palateFlavor" => note.palate_flavor,
        "notesAdvance.palateLength" => note.palate_length.to_i.to_s,
        "notesAdvance.palateOther" => note.palate_other,
        "notesAdvance.conclusionQuality" => note.conclusion_quality,
        "notesAdvance.conclusionReason" => note.conclusion_reason,
        "notesAdvance.conclusionDrinkwindow" => note.drinkwindow,
        "notesAdvance.conclusionOther" => note.conclusion_other
      }
      path = "#{PRE_PATH}#{base_url}"
      response =  Notes::NoteAgent.post(:path => path, :body => body.delete_if{|k, v| v.blank?})
      response ? JSON.parse(response.body) : false
    end
  end
end