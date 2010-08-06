class Consumption < ActiveRecord::Base
  belongs_to :profile
  belongs_to :product_category

  validates_uniqueness_of :product_category_id, :scope => :profile_id

  xss_terminate :only => [ :aditional_specifications ], :on => 'validation'

end