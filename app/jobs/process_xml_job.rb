require'nokogiri'

class ProcessXmlJob < ApplicationJob
  queue_as :default
  def perform(document_id, xml_content)
    document = Document.find(document_id)
    
    doc = Nokogiri::XML(xml_content)
    
    namespaces = { 'nfe' => 'http://www.portalfiscal.inf.br/nfe' }
    
    serie = doc.at_xpath('//nfe:serie', namespaces)&.text
    nNF = doc.at_xpath('//nfe:nNF', namespaces)&.text
    dhEmi = doc.at_xpath('//nfe:dhEmi', namespaces)&.text
    emit = doc.at_xpath('//nfe:emit//nfe:xNome', namespaces)&.text
    dest = doc.at_xpath('//nfe:dest//nfe:xNome', namespaces)&.text

    products = doc.xpath('//nfe:det', namespaces).map do |product|
      {
        name: product.at_xpath('nfe:prod/nfe:xProd', namespaces)&.text,
        ncm: product.at_xpath('nfe:prod/nfe:NCM', namespaces)&.text,
        cfop: product.at_xpath('nfe:prod/nfe:CFOP', namespaces)&.text,
        ucom: product.at_xpath('nfe:prod/nfe:uCom', namespaces)&.text,
        qcom: product.at_xpath('nfe:prod/nfe:qCom', namespaces)&.text,
        vuncom: product.at_xpath('nfe:prod/nfe:vUnCom', namespaces)&.text
      }
    end
    
    icms = doc.at_xpath('//nfe:imposto/nfe:ICMS/nfe:ICMS00/nfe:vICMS', namespaces)&.text
    ipi = doc.at_xpath('//nfe:imposto/nfe:IPI/nfe:IPITrib/nfe:vIPI', namespaces)&.text
    pis = doc.at_xpath('//nfe:imposto/nfe:PIS/nfe:PISNT/nfe:CST', namespaces)&.text
    cofins = doc.at_xpath('//nfe:imposto/nfe:COFINS/nfe:COFINSNT/nfe:CST', namespaces)&.text

    total_prod_value = products.sum { |product| product[:qcom].to_f * product[:vuncom].to_f }
    total_tax_value = icms.to_f + ipi.to_f + (pis.to_f || 0) + (cofins.to_f || 0)

    report = {
      tax_document: {
        serie: serie,
        nNF: nNF,
        dhEmi: dhEmi,
        emit: emit,
        dest: dest
      },
      products: products,
      taxes: {
        icms: icms,
        ipi: ipi,
        pis: pis,
        cofins: cofins
      },
      totalizers: {
        total_prod_value: total_prod_value,
        total_tax_value: total_tax_value
      }
    }

    puts report.to_json

    Report.create!(document: document, data: report)
  end
end 
