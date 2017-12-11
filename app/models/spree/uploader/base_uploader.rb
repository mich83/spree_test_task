# Base class for all file uploaders
# Each child should implement its own :attributes method which should convert hash with object fields to attributes structure
# If structure key ends on _attributes it is supposed that association attributes are given
# Also each child should define model class by invoking model class method "model", for example:
#     model :products
# and should define allowed mime types by invoking model class method "mime", for example:
#     mime 'text/plain' => :csv

class Spree::Uploader::BaseUploader
  class << self
    attr_reader :model_class, :mime_types

    def initialize
      @model_class = nil
      @mime_types = {}
    end

    # define model helper
    def model(model_name)
      @model_class = "spree/#{model_name}".classify.constantize
    end

    # define mime types helper
    # accepts hash like { 'mime_type' => :helper_class }
    # helper class should be defined as Spree::Uploader::Helpers::HelperClass
    def mime(mime_types)
      @mime_types = mime_types
    end

    # get path for model
    def model_path
      @model_class.to_s.underscore.split('/').last.pluralize
    end
  end

  def klass
    @klass ||= self.class
  end

  def mime_types
    @mime_types ||= klass.mime_types
  end

  # expects Spree::FileUpload object
  def initialize(file_upload)
    @file_upload = file_upload
  end

  # uploaded mime type
  def file_mime_type
    @file_mime_type ||= @file_upload.file.content_type
  end

  # we can upload if model is defined, mime types are defined and include uploaded file type
  def can_upload?
    klass.model_class && mime_types && mime_types.keys.include?(file_mime_type)
  end

  # abstract method to process loaded attributes
  def attributes(_record)
    raise 'Abstract method attributes should be overriden'
  end

  # create object based on attributes
  def process_item(item_attributes, errors)
    item = klass.model_class.new
    builder = Spree::Uploader::ObjectBuilder.new(item, errors)
    builder.build(item_attributes)
  end

  # helper class for given mime type
  def helper_class
    @helper_class ||= "spree/uploader/helpers/#{mime_types[file_mime_type]}".classify.constantize
  end

  # builds array of unsaved ActiveRecord objects, validates them and additionally returns errors if any
  def build_data_array
    table = helper_class.new(@file_upload.file.path).to_table # # load data to array of hashes
    errors = []
    data = table.map do |item_hash|
      process_item(attributes(item_hash), errors)
    end
    [data, errors]
  end

  # upload file to database
  def upload_file
    return { success: false } unless can_upload?
    data, errors = build_data_array
    if errors.any? # save errors to model id any
      { success: false, error_messages_text: errors.flatten.join("\n") }
    else
      if self.class.model_class.import(data, recursive: true, validate: false) # bulk insert
        { success: true }
      else
        { success: false }# unknown error happened
      end
    end
  end

  def upload
    @file_upload.update_attributes(upload_file)
  end
end