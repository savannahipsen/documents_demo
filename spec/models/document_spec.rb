require 'rails_helper'

describe Document, :type => :model do

  context "a document is valid with a name" do
    let(:document) { create :document, :with_file_upload}

    it "should create a valid document" do
      expect(document).to be_valid
    end
  end

  context "a document is invalid without a name" do
    let(:document) { create :document, :without_name, :with_file_upload}

    it "should require a username" do
      expect(document).not_to be_valid
    end
  end

  context "a document has an associated 'file upload' attached" do
    describe "#size" do
      let(:document) { create :document, :with_file_upload }

      it "returns the size of the associated file upload" do
        expect(document.size).to eq(document.file_upload.blob.byte_size)
      end
    end

    describe "#mime_type" do
      let(:document) { create :document, :with_file_upload }

      it "returns the mime type of the associated file upload" do
        expect(document.mime_type).to eq(document.file_upload.blob.content_type)
      end
    end
  end

end