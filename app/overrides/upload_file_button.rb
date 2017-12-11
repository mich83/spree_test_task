# Add file upload button for all models which have uploader defined
files = Dir.glob("#{Rails.root}/app/models/spree/uploader/*.rb")
files.each do |file|
  uploader_class_name = File.basename(file, '.rb')
  next if uploader_class_name == 'base_uploader' # it's an abstract class and we have to skip it.
                                                 # if we create a gem it could be removed
  uploader_class = "spree/uploader/#{uploader_class_name}".classify.constantize
  Deface::Override.new(virtual_path: "spree/admin/#{uploader_class.model_path}/index",
                     name: 'upload_file_button',
                     insert_after: 'erb:contains("content_for :page_actions do")',
                     text: "<%= button_link_to Spree::FileUpload.model_name.human, new_admin_file_upload_url(loader: '#{uploader_class_name}'), { class: 'btn-warning', icon: 'add', id: 'admin_file_upload' } %>")
end