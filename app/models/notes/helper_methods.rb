# encoding: utf-8
module Notes::HelperMethods
  # 位不齐
  def self.polishing(string, max = 3)
    "0"*(max - string.to_s.length)+string.to_s
  end

  # 他还品鉴了这些酒
  def self.build_user_notes(result)
    new_array = []
    result['data'].each do |note|
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
  def self.build_wine_notes(result)
    new_array = []
    result['data'].each do |note|
      new_array <<  {
          :user => User.find(note['uid']),
          :note => Notes::NoteItem::Note.new(note),
          :vintage => note['vintage']
      }
    end
    new_array
  end

  # 首页
  def self.build_all_notes(result)
    new_array = []
    result['data'].each do |note|
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

end
