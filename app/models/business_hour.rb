class BusinessHour < ApplicationRecord
  belongs_to :franchise

  validates :day, presence: true, inclusion: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
  validates :morning_start_time, presence: true
  validates :morning_end_time, presence: true
  validates :afternoon_start_time, presence: true
  validates :afternoon_end_time, presence: true

  def morning_start_time
    time = self[:morning_start_time].to_s(:time)
    hour, minutes = time.split(':')
    if minutes == '00'
      return "#{hour}h"
    end
    time
  end

  def morning_end_time
    time = self[:morning_end_time].to_s(:time)
    hour, minutes = time.split(':')
    if minutes == '00'
      return "#{hour}h"
    end
    time
  end

  def afternoon_start_time
    time = self[:afternoon_start_time].to_s(:time)
    hour, minutes = time.split(':')
    if minutes == '00'
      return "#{hour}h"
    end
    time
  end

  def afternoon_end_time
    time = self[:afternoon_end_time].to_s(:time)
    hour, minutes = time.split(':')
    if minutes == '00'
      return "#{hour}h"
    end
    time
  end
end
