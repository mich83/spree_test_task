# model to store pending file uploads
class Spree::FileUpload < ApplicationRecord
  has_attached_file :file
  do_not_validate_attachment_file_type :file
  validates_presence_of :file, :uploader

  after_commit :upload, on: :create # process in background

  def uploader_class
    uploader.classify.constantize
  end

  def status
    if success.nil?
      :pending
    elsif success
      :successful
    else
      :failed
    end
  end

  def upload
    Spree::Uploader::FileLoaderJob.perform_later(id)
  end
end
