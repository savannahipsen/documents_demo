require 'faraday'
require 'json'

module FilelyApi
  class Document

    def initialize(document)
      @document = document
      @tags = @document.tags
    end

    def post_to_filely
      Request.upload_document(@document, @tags)
    end

    class Request
      class << self

        BASE = 'http://filely-api-load-balancer-1100737105.us-west-2.elb.amazonaws.com:4040/objects'

        def upload_document(api_document, tags_array)

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.request :multipart
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          # smelly...
          document = ApplicationRecord::Document.find(api_document.id)

          file_upload_path = ActiveStorage::Blob.service.path_for(document.file_upload.blob.key)
          file_info = document.file_upload.blob

          payload = {
            size: file_info.byte_size,
            tags: tags_array.to_json,
            metadata: metadatify_attributes(document),
            name: document.name,
            mime_type: file_info.content_type,
            document: Faraday::UploadIO.new(file_upload_path, 'image/jpeg')
          }


          response = @connection.post do |request|
            request.path = BASE
            request.body = payload
          end

          uuid = response.body
          document.update_attribute(:uuid, uuid)
          document.save!
        end

        def update_document_tags(document)
          new_tags_array = document.tags

          path = "#{BASE}/#{document.uuid}/tags.json"

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          response = @connection.put do |request|
            request.path = path
            request.body = new_tags_array.to_json
          end

          response.body
        end

        def update_document_metadata(document)
          new_metadata = metadatify_attributes(document)

          path = "#{BASE}/#{document.uuid}/metadata.json"

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          response = @connection.put do |request|
            request.path = path
            request.body = new_metadata
          end

          response.body
        end

        def update_document_name(document)
          new_document_name = document.name

          path = "#{BASE}/#{document.uuid}/name"

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          response = @connection.put do |request|
            request.path = path
            request.body = new_document_name
          end

          response.body
        end

        def update_document_mime_type(document)
          new_document_mime_type = document.file_upload.blob.content_type
          path = "#{BASE}/#{document.uuid}/mime_type"

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          response = @connection.put do |request|
            request.path = path
            request.body = new_document_mime_type
          end

          response.body
        end

        def update_document_size(document)
          new_document_size = document.file_upload.blob.byte_size
          path = "#{BASE}/#{document.uuid}/size"

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          response = @connection.put do |request|
            request.path = path
            request.body = new_document_size.to_json
          end

          response.body
        end

        # not yet implemented in filely
        def get_all_available_tags
          path = "#{BASE}/tags.json"

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          response = @connection.get do |request|
            request.path = path
            # request.body = {}
          end

          response.body
        end

        def get_document_tags(document_uuid)
          path = "#{BASE}/#{document_uuid}/tags.json"

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          response = @connection.get do |request|
            request.path = path
          end

          response.body
        end

        def get_document_details(document_uuid)
          path = "#{BASE}/#{document_uuid}.json"

          @connection = Faraday.new(url: BASE) do |faraday|
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end

          response = @connection.get do |request|
            request.path = path
          end
          response.body
        end

        def search_documents_by_metadata(metadata)
          return unless metadata

          metadata_params = metadata[0].gsub(/\s+/, "")
          path = "#{BASE}/metadata.json?and=#{metadata_params}"

          response = Faraday.get(path)
          response.body
        end



        def search_documents_by_tags(tag_names)
          return unless tag_names

          tag_list = tag_names[0].gsub(/\s+/, "")
          and_path = "#{BASE}/tags.json?and=#{tag_list}"
          # or_path = "#{BASE}/tags.json?or=#{tag_list}"

          response = Faraday.get(and_path)
          response.body
        end

        def errors(response)
          error = { errors: { status: response["status"], message: response["message"] } }
          response.merge(error)
        end

        private

        def metadatify_attributes(document)
          account_id_string = document.account_id.to_s
          metadata = document.attributes.slice("file_owner").merge("account_id" => account_id_string)
          metadata.to_json
        end
      end
    end

  end
end
