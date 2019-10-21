class Document < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ActiveModel::Conversion

  has_one_attached :file_upload

  attr_accessor :tags

  validates_presence_of :name
  validates_presence_of :account_id
  validates_presence_of :file_upload

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
    unless tags_from_filely == "null" || tags_from_filely.nil?
      parsed_tags = JSON.parse(tags_from_filely)
      parsed_tags.map! { |tag| tag.strip.downcase.tr("_", " ") }
    end
    parsed_tags.present? ? parsed_tags : []
  end

  def fetch_document_metadata
    document_uuid = self.uuid
    metadata_from_filely = FilelyApi::Document::Request.get_document_metadata(document_uuid)
    unless metadata_from_filely == "null" || metadata_from_filely.nil?
      parsed_metadata = JSON.parse(metadata_from_filely)
      parsed_metadata.each { |k, v| parsed_metadata[k] = v.tr("_", " ").titleize }

      self.account_id = parsed_metadata["account_id"]
      self.file_owner = parsed_metadata["file_owner"]
      self.save!
    end
  end

  def post_document
    api_document = FilelyApi::Document.new(self)
    api_document.post_to_filely
  end

  def post_document_updates
    #TODO: so bad... need to check which attr changed...
    FilelyApi::Document::Request.update_document_name(self)
    FilelyApi::Document::Request.update_document_tags(self)
    FilelyApi::Document::Request.update_document_mime_type(self)
    FilelyApi::Document::Request.update_document_size(self)
    FilelyApi::Document::Request.update_document_metadata(self)
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


