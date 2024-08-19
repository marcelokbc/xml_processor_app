class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:query].present?
      query_params = "%#{params[:query]}%"
      
      @documents = current_user.documents
                       .joins(:report)
                       .joins("INNER JOIN active_storage_attachments ON active_storage_attachments.record_id = documents.id AND active_storage_attachments.record_type = 'Document'")
                       .joins("INNER JOIN active_storage_blobs ON active_storage_blobs.id = active_storage_attachments.blob_id")
                       .where(
                         "active_storage_blobs.filename ILIKE :query OR
                          reports.data->'tax_document'->>'nNF' ILIKE :query OR
                          reports.data->'tax_document'->>'emit' ILIKE :query OR
                          reports.data->'tax_document'->>'dest' ILIKE :query OR
                          EXISTS (
                            SELECT 1 FROM jsonb_array_elements(reports.data->'products') AS product
                            WHERE product->>'name' ILIKE :query
                          )",
                         query: query_params
                       )
    else
      @documents = current_user.documents
    end
  end
  
  def show
    @document = Document.find(params[:id])
    
    if@document.report
      @report = JSON.parse(@document.report.data)
    else
      flash[:alert] = "Relatório ainda não disponível."
      redirect_to documents_path
    end
  end

  def new
    @document = Document.new
  end
  
  def create
    @document = current_user.documents.build(document_params)
    
    if @document.save
      #xml_content = @document.file.download
      doc = Document.find(@document.id)
      
      ProcessXmlJob.perform_later(@document.id, doc.file.download)
      
      flash[:success] = "Documento enviado com sucesso. Processando o arquivo..."
      redirect_to document_path(@document)
    else
      flash[:error] = "Erro ao enviar o documento."
      render :new, status::unprocessable_entity
    end
  end
  
  def search
  if params[:query].present?
    @documents = current_user.documents.joins(:report).where(
      "reports.data->'tax_document'->>'nNF' ILIKE :query OR reports.data->'tax_document'->>'emit' ILIKE :query OR reports.data->'tax_document'->>'dest' ILIKE :query",
      query: "%#{params[:query]}%"
    )
  else
    flash[:alert] = "Digite algo para pesquisar."
    redirect_to documents_path
  end
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end 
end
