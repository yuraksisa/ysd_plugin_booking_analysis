module YsdPluginBookingAnalysis
  class BookingAnalysisQueriesMysql
    def initialize(repository)
      @repository = repository
    end
    def booking_cummulative_received_reservations(received_from, received_to)

      query = <<-QUERY
         select data.date, data.total, 
               (select count(*) as cummulative 
                from bookds_bookings where status not in (1,5) and creation_date >= ? and creation_date <= ? and 
                                           date_format(creation_date,'%Y-%m-%d') <= data.date) as cummulative
         from
          (select date_format(creation_date,'%Y-%m-%d') as date, count(*) as total
           from bookds_bookings
           where status not in (1,5) and creation_date >= ? and creation_date <= ?
           group by date) as data
         order by data.date asc
      QUERY

      data = repository.adapter.select(query, received_from, received_to, received_from, received_to)

    end
  end
end