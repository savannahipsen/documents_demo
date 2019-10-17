class Document < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ActiveModel::Conversion

  has_one_attached :file_upload

  attr_accessor :tags

  validates_presence_of :name
  validates_presence_of :account_id

  def size
    file_upload.attached? ? self.file_upload.blob.byte_size : 0
  end

  def display_size
    file_upload.attached? ? number_to_human_size(self.file_upload.blob.byte_size) : number_to_human_size(0)
  end

  def mime_type
    file_upload.attached? ? self.file_upload.blob.content_type : "No file"
  end

  def fetch_document_tags
    document_uuid = self.uuid
    tags_from_filely = FilelyApi::Document::Request.get_document_tags(document_uuid)
    JSON.parse(tags_from_filely)
  end

  def post_document
    api_document = FilelyApi::Document.new(self)
    api_document.post_to_filely
  end

  def post_document_updates
    # so smelly
    FilelyApi::Document::Request.update_document_name(self)
    FilelyApi::Document::Request.update_document_tags(self)
    FilelyApi::Document::Request.update_document_mime_type(self)
    FilelyApi::Document::Request.update_document_size(self)
  end

  def self.fetch_all_tags
    FilelyApi::Document::Request.get_all_available_tags
  end

  def self.search_by_tags(tags)
    FilelyApi::Document::Request.search_documents_by_tags(tags)
  end

  def self.search_by_metadata(metadata)
    FilelyApi::Document::Request.search_documents_by_metadata(metadata)
  end

end


