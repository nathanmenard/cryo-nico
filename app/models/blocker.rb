class Blocker < ApplicationRecord
  belongs_to :blocker, optional: true
  belongs_to :franchise
  belongs_to :room
  belongs_to :user

  has_many :blockers, dependent: :destroy

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :notes, presence: true

  before_save :round_minutes
  after_create :clone_if_global
  after_update :update_children_if_global

  scope :today, -> { where(start_time: Date.today.all_day) }

  def self.by_time(time)
    data = []
    all.each do |blocker|
      hour = blocker.start_time.hour.to_i
      minutes = blocker.start_time.strftime('%M').to_i
      hour_2, minutes_2 = time.split(':').map(&:to_i)
      if (hour == hour_2) && (minutes == minutes_2)
        data << blocker
      end
    end
    data
  end

  def duration
    (end_time - start_time) / 60
  end

  def height
    case duration
    when 30
      22
    when 60
      50
    when 90
      80
    when 120
      110
    when 150
      145
    when 180
      175
    end
  end

  private

  def clone_if_global
    return if !global
    return if blocker

    clone = self.attributes
    clone.except!('id')
    clone['blocker_id'] = id
    room.franchise.rooms.where.not(id: room.id).each do |r|
      r.blockers.create!(clone)
    end
  end

  def update_children_if_global
    return if !global
    return if blocker

    clone = self.attributes
    clone.except!('id', 'blocker_id', 'room_id')
    blockers.each do |b|
      b.update!(clone)
    end
  end

  def round_minutes
    return if start_time.blank?
    if new_record? || start_time_changed?
      time = start_time.to_time.to_s
      minutes = time.split(':')[1].to_i
      if minutes <= 15
        new_start_time = start_time.beginning_of_hour
      end
      if minutes > 15
        new_start_time = start_time.beginning_of_hour + 30.minutes
      end
      if minutes > 30
        new_start_time = start_time.beginning_of_hour + 30.minutes
      end
      if minutes >= 45
        new_start_time = (start_time + 1.hour).beginning_of_hour
      end
      self.start_time = new_start_time
    end
  end
end
