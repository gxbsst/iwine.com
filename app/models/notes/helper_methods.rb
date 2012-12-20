# encoding: utf-8
module Notes::HelperMethods
  # 位不齐
  def self.polishing(string, max = 3)
    "0"*(max - string.to_s.length)+string.to_s
  end

  # 他还品鉴了这些酒
  def self.build_user_notes(result, filter_draft = true)
    new_array = []
    result['data'].each do |note|
      next if note['statusFlag'].to_i == Note::STATUS_FLAG[:draft]  if  filter_draft
      new_array <<  {
          :user => User.find(note['uid']),
          :wine => Notes::NoteItem::Wine.new(note['wine']),
          :note => Notes::NoteItem::Note.new(note),
          :photo => Notes::NoteItem::Photo.new(note['cover'])
      }
    end
    new_array 
  end

  # 他们也品鉴了这支酒
  def self.build_wine_notes(result, filter_draft = true)
    new_array = []
    result['data'].each do |note|
      next if note['statusFlag'].to_i == Note::STATUS_FLAG[:draft] if  filter_draft
      new_array <<  {
          :user => User.find(note['uid']),
          :note => Notes::NoteItem::Note.new(note),
          :vintage => note['vintage']
      }
    end
    new_array
  end

  # 首页
  def self.build_all_notes(result, filter_draft = true, sync_local = false)
    new_array = []
    result['data'].each do |note|
      next if note['statusFlag'].to_i == Note::STATUS_FLAG[:draft]  if  filter_draft
      Note.init_main_data(note) if sync_local
      new_array <<  {
          :location => Notes::NoteItem::Location.new(note),
          :user => User.find(note['uid']),
          :note => Notes::NoteItem::Note.new(note),
          :photo => Notes::NoteItem::Photo.new(note),
          :wine =>  Notes::NoteItem::Wine.new(note)
      }
    end
    new_array
  end
  
  #同时将关键信息拉到数据库里
  def self.build_and_sync_all_notes(result)
    build_all_notes(result,true, true)
  end
end
