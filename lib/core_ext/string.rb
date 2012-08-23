# encoding: UTF-8
class String

  ## 检测是否为中文, 日文， 韩文
  ## http://stackoverflow.com/questions/5064344/how-to-determine-wide-chars-in-ruby-chinese-japanese-korean
  def contains_cjk?
    !!(self =~ /\p{Han}|\p{Katakana}|\p{Hiragana}\p{Hangul}/)
  end

end
