require 'rails_helper'

describe DocumentsController, :type => :controller do

  describe "GET /index" do
    it "has a 200 status code" do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe "GET /new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe "POST /create" do
    let(:document) { create :document }

    it "instantiates the @document" do
      document_params = {name: 'My Test Document', account_id: "827364"}
      allow(Document).to receive(:new).and_return(document)
      allow(document).to receive(:save).and_return(true)
      allow(document).to receive(:post_document).and_return(true)
      strong_params = ActionController::Parameters.new(document_params).permit!
      expect(Document).to receive(:new).with(strong_params)
      post :create, params: {document: strong_params}
      expect(assigns[:document]).to eq(document)
    end
  end

  describe "DELETE /destroy" do
    let(:document) { create :document }

    it "deletes the @document" do
      allow(Document).to receive(:find).and_return(document)
      expect(document).to receive(:destroy).and_return(true)
      delete :destroy, params: { id: document.id }
    end

    it "redirects to documents index" do
      allow(Document).to receive(:find).and_return(document)
      allow(document).to receive(:destroy).and_return(true)
      delete :destroy, params: { id: document.id }
      expect(response).to redirect_to(documents_path)
    end
  end

end
