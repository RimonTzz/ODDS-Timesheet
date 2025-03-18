class Site < ApplicationRecord
  belongs_to :client, optional: true
  has_many :timesheets
  has_many :projects, dependent: :destroy 
end
