class Brick < ActiveRecord::Base
  validates_presence_of :name
  validate :valid_email?
  
  validate do |b|
    b.errors.add(:value_in_pounds, "The minimum donation is £2.00") if b.value < 200
    b.errors.add(:value_in_pounds, "The maximum donation is £500. Please contact us directly at donations@childsifoundation.org if you wish to donate more.") if b.value > 500_00
  end
  
  def value_in_pounds
    value.nil? ? nil : format('%.2f', (value/100.0) || 0)
  end
  def value_in_pounds=(a)
    return if a.nil?
    a = a.to_f if a.kind_of? String
    self.value=(a*100).to_i
  end
  
  def valid_email?
    TMail::Address.parse(email) unless email.blank?
  rescue
    errors.add_to_base("Must be a valid email")
  end
  
  def protx_hash
    hash = {
      'Amount' => value,
      'Currency' => 'GBP',
      'Description' => "Buy-a-brick: #{message}",
    }
    hash['CustomerEMail'] = email unless email.blank?
    hash
  end
end