class Wall
  attr_accessor :bricks, :total
  
  def initialize
    self.bricks = Brick.find(:all, :conditions => 'purchased_at IS NOT NULL', :order => 'purchased_at DESC', :limit => 100)
    self.total = Brick.sum(:value, :conditions => 'purchased_at IS NOT NULL') / 100.0
  end
end