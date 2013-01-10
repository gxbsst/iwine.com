# encoding: utf-8

module IdentifyCardValidator
  ARRINT = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
  ARRCH = %W(1 0 X 9 8 7 6 5 4 3 2)
  class << self
    def change18(card)
      if card.size == 15
        chars = card.chars.to_a
        cardtemp = 0
        chars.insert(6,'1','9')
        17.times do |i|
          cardtemp += (chars[i].to_i * ARRINT[i])
        end
        (chars << ARRCH[cardtemp % 11])
      else
        #raise card + '并非15位身份证号!'
        return false
      end
    end

    def check(card)
      case card.size
        when 15
          chars = change18(card)
        when 18
          chars = card.chars.to_a
        else
          #raise '无法识别身份证号!'
          return false
      end
      cardtemp = 0
      17.times do |i|
        cardtemp += chars[i].to_i * ARRINT[i]
      end
      ARRCH[cardtemp % 11].eql? chars.last
    end
  end
end

class IdentifyCardFormatValidator < ActiveModel::EachValidator
  #include ::IndentifyCardValidator
  def validate_each(object, attribute, value)
    unless ::IdentifyCardValidator.check(value)
      #object.errors.add(attribute, :indentify_card_format, options)
      object.errors[attribute] << (options[:message] || "无法识别身份证号")
    end
  end

end
