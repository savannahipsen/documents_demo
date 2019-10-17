class AddFileOwnerAndUuidToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :uuid, :string
    add_column :documents, :file_owner, :string
  end
end
