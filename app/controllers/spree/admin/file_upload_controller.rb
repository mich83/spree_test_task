class Spree::Admin::FileUploadController < Spree::Admin::BaseController
  def new
    @uploader_class = uploader_class
    if @uploader_class
      @loader_class_name = params[:loader]
    else
      redirect_to admin_path
    end
  end

  def create
    file_upload = Spree::FileUpload.new(file_upload_attributes)
    if file_upload.save
      redirect_to action: :index, params: redirect_params
    else
      flash[:error] = error_message(file_upload).join(' ')
      redirect_to action: :new, params: redirect_params
    end
  end

  def index
    @uploader_class = uploader_class
    if @uploader_class
      @file_uploads = Spree::FileUpload.where(uploader: @uploader_class.to_s.underscore).order(created_at: :desc)
    else
      redirect_to admin_path
    end
  end

  def uploader_class
    uploader_class_name = "spree/uploader/#{params[:loader]}".classify
    if Object.const_defined?(uploader_class_name)
      uploader_class_name.constantize
    end
  end

  def redirect_params
    @redirect_params ||= { loader: file_upload_attributes[:uploader].split('/').last }
  end

  def file_upload_attributes
    @file_upload_attributes ||= params.require(:file_upload).permit(:uploader, :file)
  end

  def error_message(model)
    messages = model.errors.full_messages
    [Spree.t('errors_prohibited_this_record_from_being_saved', count: messages.count)] +  messages
  end
end