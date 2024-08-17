class Document < ApplicationRecord
  belongs_to :user
  
  has_one_attached :file
  has_one :report, dependent: :destroy
end
