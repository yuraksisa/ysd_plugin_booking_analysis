require 'ysd_md_booking' unless defined?(BookingDataSystem::Booking)

module YsdPluginBookingAnalysis
  module BookingAnalysisQueries
    #
    # Get a summary of reservation received between received_from and
    # received_to dates that correspond a reservations which start
    # start date is between reservation_start_from and reservation_start_to
    #
    #
    #
    def booking_received_reservations(received_from, received_to,
                                     reservation_start_from, reservation_start_to)

      query = <<-QUERY
         select count(*) as total, sum(total_cost) as total_cost,
                round(avg(days)) as avg_days, round(avg(total_cost)) as avg_total_cost,
                round(min(days)) as min_days, round(min(total_cost)) as min_total_cost,
                round(max(days)) as max_days, round(max(total_cost)) as max_total_cost 
         from bookds_bookings as b
         where b.creation_date >= ? and b.creation_date <= ? and 
               b.date_from >= ? and b.date_from <= ? and
               b.status NOT IN (1,5)
      QUERY

      data = repository.adapter.select(query, received_from, received_to, reservation_start_from, reservation_start_to).first

    end
  end

  BookingDataSystem::Booking.extend(BookingAnalysisQueries)

end