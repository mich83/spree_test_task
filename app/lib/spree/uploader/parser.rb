# Utility module to string
module Spree::Uploader::Parser
  def parse_datetime(str)
    return unless str
    DateTime.parse(str)
  rescue ArgumentError => err
  end

  # helper method to convert string to float value
  # accepts , and . as decimal delimiter. When incorrect value given returns nil
  def parse_float(value)
    Float(value.to_s.gsub(',','.'))
  rescue ArgumentError
    nil
  end
end