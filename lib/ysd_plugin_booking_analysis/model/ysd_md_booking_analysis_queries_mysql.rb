module YsdPluginBookingAnalysis
  class BookingAnalysisQueriesMysql

    def initialize(repository)
      @repository = repository
    end

    def reservations_received_by_creation_date(year)

      query = <<-QUERY
             SELECT DATE_FORMAT(creation_date, '%Y-%m') as period, 
                 count(*) as occurrences
             FROM bookds_bookings
             WHERE YEAR(creation_date) = #{year.to_i}
             GROUP BY period
             ORDER by period
      QUERY

      reservations=@repository.adapter.select(query)

    end

    def reservations_confirmed_by_creation_date(year)

      query = <<-QUERY
             SELECT DATE_FORMAT(creation_date, '%Y-%m') as period, 
                 count(*) as occurrences
             FROM bookds_bookings
             WHERE status NOT IN (1,5) and YEAR(creation_date) = #{year.to_i}
             GROUP BY period 
             ORDER by period
      QUERY

      reservations=@repository.adapter.select(query)

    end

    def reservations_confirmed_by_reservation_date(year)

      query = <<-QUERY
             SELECT DATE_FORMAT(date_from, '%Y-%m') as period, 
                 count(*) as occurrences
             FROM bookds_bookings
             WHERE status NOT IN (1,5) and YEAR(date_from) = #{year.to_i}
             GROUP BY period 
             ORDER by period
      QUERY

      reservations=@repository.adapter.select(query)

    end

    def incoming_money_summary(year)

      query = <<-QUERY
             SELECT DATE_FORMAT(date_from, '%Y-%m') as period, 
                 sum(total_cost) as total
             FROM bookds_bookings
             WHERE status IN (2,3,4) and YEAR(date_from) = #{year.to_i}
             GROUP BY period
             ORDER by period
      QUERY

      summary = @repository.adapter.select(query)

    end

    def invoicing_by_sales_channel(year)

      query = <<-QUERY
             SELECT DATE_FORMAT(date_from, '%Y-%m') as period, sales_channel_code, sum(total_cost) as total
             FROM bookds_bookings
             WHERE status IN (2,3,4) and YEAR(date_from) = #{year.to_i}
             GROUP BY period, sales_channel_code
             ORDER by period, sales_channel_code
      QUERY

      summary = @repository.adapter.select(query)

    end

    def invoicing_by_product_category(year)

      query = <<-QUERY
             SELECT bl.item_id, sum(bl.item_cost) as total
             FROM bookds_bookings as b
             JOIN bookds_bookings_lines as bl on b.id = bl.booking_id
             WHERE status IN (2,3,4) and YEAR(date_from) = #{year.to_i}
             GROUP BY item_id
             ORDER by item_id
      QUERY

      summary = @repository.adapter.select(query)

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