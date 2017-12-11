class Spree::Uploader::FileLoaderJob < ApplicationJob
  queue_as :default

  def perform(file_upload_id)
    file_upload = Spree::FileUpload.find(file_upload_id)
    uploader = file_upload.uploader_class.new(file_upload)
    uploader.upload
  end
end
