namespace :review do
  task ask: :environment do
    reservations = Reservation.finished_yesterday
    reservations.each do |reservation|
      ClientMailer.ask_for_review(reservation).deliver_now
    end
  end
end
