class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @documents = current_user.documents
  end

  def show
  @document = Document.find(params[:id])

    if@document.report
      @report = @document.report.data
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
    
    if@document.save
      ProcessXmlJob.perform_later(@document.id)
      flash[:success] = "Documento enviado com sucesso. Processando o arquivo..."
      redirect_to document_path(@document)
    else
      flash[:error] = "Erro ao enviar o documento."
      render :new, status::unprocessable_entityend
    end
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end 
end
