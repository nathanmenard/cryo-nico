class CouponsFranchise < ApplicationRecord
  belongs_to :coupon
  belongs_to :franchise
end
