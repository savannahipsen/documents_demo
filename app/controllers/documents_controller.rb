class DocumentsController < ApplicationController

  before_action :set_document, only: [:show, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all
  end

  def search
    # so gross
    return unless params[:tags] || params[:metadata]
    tags = params[:tags]
    metadata = params[:metadata]

    if params[:tags].all?(&:present?)
      @documents = Document.search_by_tags(tags)
    elsif params[:metadata].all?(&:present?)
      @documents = Document.search_by_metadata(metadata)
    end

    @documents
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    @tags = @document.fetch_document_tags || []
    @metadata = @document.fetch_document_metadata
  end

  # GET /documents/new
  def new
    @document = Document.new
    @tags = []
    # TODO: implement when endpoint in Filey
    # all_available_tags = Document.fetch_all_tags
    # @tags = JSON.parse(all_available_tags) || []
  end

  # GET /documents/1/edit
  def edit
    @document = Document.find(params[:id])
    @tags = @document.fetch_document_tags || []
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)
    assign_document_tags(params["tags"])
    # saving document for the file_upload.blob information (mime_type, size)
    if @document.save && @document.post_document
    # if @document.post_document
      redirect_to @document, notice: 'Document was successfully created.'
    else
      render 'new'
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    if params["tags"]
      assign_document_tags(params["tags"])
    end
    # updating document for the file_upload.blob information (mime_type, size)
    if @document.update(document_params) && @document.post_document_updates
      redirect_to @document, notice: 'Document was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
      redirect_to documents_url, notice: 'Document was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    def assign_document_tags(document_tags)
      @document.tags = document_tags
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:name, :account_id, :file_upload, :metadata, :file_owner)
    end
end
