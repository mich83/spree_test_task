class CreateSpreeFileUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_file_uploads do |t|
      t.text :error_messages_text
      t.string :uploader
      t.boolean :success
      t.attachment :file

      t.timestamps
    end
  end
end
