class CouponMailer < ApplicationMailer
  def loyalty(coupon)
    @coupon = coupon
    person = @coupon.client ? @coupon.client : @coupon.company_client
    mail(to: person.email, subject: '20€ offerts sur votre prochaine réservation')
  end
end
