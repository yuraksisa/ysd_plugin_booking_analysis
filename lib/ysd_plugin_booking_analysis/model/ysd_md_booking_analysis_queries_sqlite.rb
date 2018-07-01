module YsdPluginBookingAnalysis
  class BookingAnalysisQueriesSqlite

    def initialize(repository)
      @repository = repository
    end

    def reservations_received_by_creation_date(year)

      query = <<-QUERY
             SELECT TO_CHAR(creation_date, 'YYYY-MM') as period, 
                 count(*) as occurrences
             FROM bookds_bookings and strftime('%Y', creation_date) = #{year.to_i}
             GROUP BY period
             order by period
      QUERY

      reservations=@repository.adapter.select(query)

    end

    def reservations_confirmed_by_creation_date(year)

      query = <<-QUERY
             SELECT TO_CHAR(creation_date, 'YYYY-MM') as period, 
                  count(*) as occurrences
             FROM bookds_bookings
             WHERE status NOT IN (1,5) and strftime('%Y', creation_date) = #{year.to_i}
             GROUP BY period 
             order by period
      QUERY

      reservations=@repository.adapter.select(query)

    end

    def reservations_confirmed_by_reservation_date(year)

      query = <<-QUERY
             SELECT TO_CHAR(date_from, 'YYYY-MM') as period, 
                  count(*) as occurrences
             FROM bookds_bookings
             WHERE status NOT IN (1,5) and strftime('%Y', date_from) = #{year.to_i}
             GROUP BY period 
             order by period
      QUERY

      reservations=@repository.adapter.select(query)

    end


    def incoming_money_summary(year)

      query = <<-QUERY
             SELECT TO_CHAR(date_from, 'YYYY-MM') as period, 
                 sum(total_cost) as total
             FROM bookds_bookings
             WHERE status IN (2,3,4) and strftime('%Y', date_from) = #{year.to_i}
             GROUP BY period
             ORDER by period
      QUERY

      summary = @repository.adapter.select(query)

    end

    def invoicing_by_sales_channel(year)

      query = <<-QUERY
             SELECT TO_CHAR(date_from, 'YYYY-MM') as period, sales_channel_code, sum(total_cost) as total
             FROM bookds_bookings
             WHERE status IN (2,3,4) and strftime('%Y', date_from) = #{year.to_i}
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
             WHERE status NOT IN (1,5) and date_part('year', date_from) = #{year.to_i}
             GROUP BY item_id
             ORDER by item_id
      QUERY

      summary = @repository.adapter.select(query)

    end

    #
    #
    #
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