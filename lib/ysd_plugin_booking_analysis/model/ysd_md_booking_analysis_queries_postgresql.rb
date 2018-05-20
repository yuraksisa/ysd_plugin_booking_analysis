module YsdPluginBookingAnalysis
  class BookingAnalysisQueriesPostgresql

    def initialize(repository)
      @repository = repository
    end

    #
    #
    #
    def booking_cummulative_received_reservations(received_from, received_to)
      query = <<-QUERY
         select data.date, data.total, 
               (select count(*) as cummulative 
                from bookds_bookings where status not in (1,5) and creation_date >= ? and creation_date <= ? and 
                                           to_char(creation_date,'YYYY-mm-dd') <= data.date) as cummulative
         from
          (select to_char(creation_date,'YYYY-mm-dd') as date, count(*) as total
           from bookds_bookings
           where status not in (1,5) and creation_date >= ? and creation_date <= ?
           group by date) as data
         order by data.date asc
      QUERY

      data = repository.adapter.select(query, received_from, received_to, received_from, received_to)
    end
  end
end