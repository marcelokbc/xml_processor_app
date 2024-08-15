class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @documents = current_user.documents
  end

  def new
    @document = Document.new
  end

  def create
    @document = current_user.documents.build(document_params)
    
    if @document.save
      flash[:success] = "Documento upload com sucesso"
      redirect_to documents_path
    else
      flash[:error] = "Erro ao fazer upload do documento"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end
end
