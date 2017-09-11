class Harvest < ActiveRecord::Base
  belongs_to :resource, inverse_of: :harvests
  has_many :formats, inverse_of: :harvest, dependent: :destroy
  has_many :hlogs, inverse_of: :harvest, dependent: :destroy
  has_many :nodes, inverse_of: :harvest, dependent: :destroy
  has_many :occurrences, inverse_of: :harvest, dependent: :destroy
  has_many :traits, inverse_of: :harvest, dependent: :destroy
  has_many :meta_traits, inverse_of: :harvest, dependent: :destroy

  scope :completed, -> { where("completed_at IS NOT NULL") }

  def complete
    update_attribute(:completed_at, Time.now)
    update_attribute(:time_in_minutes, (completed_at - created_at).to_i / 60)
  end
end
