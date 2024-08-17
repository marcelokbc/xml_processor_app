class Report < ApplicationRecord
  belongs_to :document

  serialize :data, coder: JSON
end
