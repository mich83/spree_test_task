class Spree::Uploader::UploaderTestHelper
  def initialize
    @rows = []
  end

  def row(values)
    @rows << values
  end

  def to_string
    CSV.generate do |csv|
      @rows.each { |row| csv << row }
    end
  end

  def to_file_upload
    Spree::FileUpload.create(file: StringIO.new(to_string), uploader: 'spree/uploader/product_uploader')
  end
end