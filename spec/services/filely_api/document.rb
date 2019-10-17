require 'rails_helper'
require 'webmock/rspec'

describe FilelyApi::Document::Request do

  BASE = 'http://filely-api-load-balancer-1100737105.us-west-2.elb.amazonaws.com:4040/objects'

  describe "#upload_document" do

    context "the post request is successful" do

      let(:document) { create :document, :with_file_upload }

      it "should return and assign the document uuid" do
        file_upload_blob = document.file_upload.blob

        headers = { 'Content-Type' => /multipart\/form-data/ }
        filely_json = {
            size: file_upload_blob.byte_size,
            tags: [],
            metadata: {},
            name: document.file_upload.name,
            mime_type: file_upload_blob.content_type,
            # document:
        }.to_json

        match_multipart_body = ->(request) do
          request.body.force_encoding('BINARY')
          # request.body =~ /Content-Type: image\/jpeg/
          request.body = filely_json
        end

        stub_request(:post, "#{BASE}").
          with(headers: headers, &match_multipart_body).
          to_return(status: 201, body: "6ydyus7f-enb3-11e9-bd29-0a58a5veac5g")

        # expect(post_document).to_return(stub)
        # stub_request(:post, "#{BASE}").with(body: filely_json)
        #   .to_return(status: 201, body: "3fdyus7f-ead9-11e9-bd29-0a58a5veac5g")

        # binding.pry
        # expect(document).to receive(:post_document)

        binding.pry
        document.post_document

        expect(document.post_document).not_to be_nil

        # expect(document.upload_document).not_to be_nil
        # expect(gateway_account.status).to eq(nil)
      end

    end
  end

  # headers = { 'Content-Type' => /multipart\/form-data/ }
  #
  # match_multipart_body = ->(request) do
  #   request.body.force_encoding('BINARY')
  #   request.body =~ /Content-Type: image\/jpeg/
  # end
  #
  # stub_request(:post, '/my-endpoint').
  #     with(headers: headers, &match_multipart_body).
  #     to_return(status: 200, body: successful_response)

  # stub_request(:post, "http://example.host:9999/axiom/boarding_requests").
  #     with(body: {"attributes"=>"{\"legal_name\":\"iTransact\",\"chain\":\"chain_value\",\"store_name\":\"PRC*Legal Account Name\",\"federal_tax_id\":7575,\"merchant_name\":\"PRC*DBA Name\",\"customer_service_phone\":\"971-843-2222\",\"environment\":\"Environment indicator\",\"swipe_perc\":50,\"est_monthly_vol\":75060,\"address1\":\"7649 Twin Peaks Dr\",\"city\":\"Atlanta\",\"state\":\"GA\",\"zip\":\"46521\",\"alt_mail_address1\":\"1212 Harvard Lane\",\"alt_mail_city\":\"Savannah\",\"alt_mail_state\":\"GA\",\"alt_mail_zip\":\"97645\",\"contact_name\":\"Lady Lou\",\"contact_phone\":\"454-792-1973\",\"card_type1\":\"VISA\",\"eqp_card_type1\":\"VISA\",\"discount_method1\":\"09\",\"discount_perc1\":0,\"card_type2\":\"MASTER\",\"eqp_card_type2\":\"MASTER\",\"discount_method2\":\"09\",\"discount_perc2\":0,\"control_owner\":{\"contact_level\":\"MCH\",\"contact_full_name\":\"Lady Lou\",\"contact_first_name\":\"Lady\",\"contact_last_name\":\"Lou\",\"address1\":\"452 Snow Dr\",\"city\":\"Houston\",\"state\":\"nowhere\",\"zip\":\"44912\",\"phone\":\"454-792-1973\",\"email\":\"ladylou@payroc.com\",\"dob\":\"08/21/1980\"}}"},
  #          headers: {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'1415', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'example.host:9999', 'User-Agent'=>'Ruby'}).
  #     to_return(status: 200, body: "", headers: {})

end

