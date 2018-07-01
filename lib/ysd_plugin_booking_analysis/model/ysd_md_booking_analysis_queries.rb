require 'ysd_md_booking' unless defined?(BookingDataSystem::Booking)

module YsdPluginBookingAnalysis
  module BookingAnalysisQueries

    #
    # Reservations received in a year grouped by received month
    #
    def reservations_received_by_creation_date(year)
      analysis_query_strategy.reservations_received_by_creation_date(year)
    end

    #
    # Confirmed reservations in a year grouped by received month
    #
    def reservations_confirmed_by_creation_date(year)
      analysis_query_strategy.reservations_confirmed_by_creation_date(year)
    end

    #
    # Confirmed reservations in a year grouped by received month
    #
    def reservations_confirmed_by_reservation_date(year)
      analysis_query_strategy.reservations_confirmed_by_reservation_date(year)
    end

    #
    # Yearly invoicing group by month
    #
    def incoming_money_summary(year)
      analysis_query_strategy.incoming_money_summary(year)
    end

    #
    # Yearly invoicing group by month and sales channel
    #
    def invoicing_by_sales_channel(year)
      analysis_query_strategy.invoicing_by_sales_channel(year)
    end

    #
    # Yearly invoicing group by category
    #
    def invoicing_by_product_category(year)
      analysis_query_strategy.invoicing_by_product_category(year)
    end

    #
    # Get a summary of reservation received between received_from and
    # received_to dates that correspond a reservations which start
    # start date is between reservation_start_from and reservation_start_to
    #
    def booking_received_reservations(received_from, received_to,
                                      reservation_start_from, reservation_start_to)

      query = <<-QUERY
         select count(*) as total,
                sum(total_cost) as total_cost,
                round(avg(days)) as avg_days, 
                round(avg(total_cost)) as avg_total_cost,
                round(min(days)) as min_days, 
                round(min(total_cost)) as min_total_cost,
                round(max(days)) as max_days, 
                round(max(total_cost)) as max_total_cost 
         from bookds_bookings as b
         where b.creation_date >= ? and b.creation_date <= ? and 
               b.date_from >= ? and b.date_from <= ? and
               b.status NOT IN (1,5)
      QUERY

      data = repository.adapter.select(query, received_from, received_to, reservation_start_from, reservation_start_to).first

      data.total = 0 if data.total.nil?
      data.total_cost = 0 if data.total_cost.nil?
      data.avg_days = 0 if data.avg_days.nil?
      data.avg_total_cost = 0 if data.avg_total_cost.nil?
      data.min_days = 0 if data.min_days.nil?
      data.min_total_cost = 0 if data.min_total_cost.nil?
      data.max_days = 0 if data.max_days.nil?
      data.max_total_cost = 0 if data.max_total_cost.nil?

      return data

    end

    #
    # Get cummulative received reservations between two dates
    #
    def booking_cummulative_received_reservations(received_from, received_to)

      # Get the data
      query_data = analysis_query_strategy.booking_cummulative_received_reservations(received_from, received_to).inject({}) do |result, item|
        result.store(item.date, item.cummulative)
        result
      end

      # Build the non received days items
      date = received_from.clone
      while date <= received_to
        date_str = date.strftime('%Y-%m-%d')
        query_data.store(date_str,0) unless query_data.has_key?(date_str)
        date=date+1
      end

      # Fill the non cummulative date
      keys = query_data.keys.sort
      keys.each_index do |index|
        query_data[keys[index]] = query_data[keys[index-1]] if query_data[keys[index]] == 0 and index > 0
      end

      # Build the sort data
      result = query_data.keys.sort.inject({}) do |result, item|
         date=Date.strptime(item,'%Y-%m-%d')
         key="#{date.month.to_s.rjust(2,'0')}-#{date.day.to_s.rjust(2,'0')}"
         result.store(key, query_data[item] || 0)
         result
      end

      p "result:#{result}"

      result

    end

    private

    def analysis_query_strategy

      if DataMapper::Adapters.const_defined?(:PostgresAdapter) and repository.adapter.is_a?DataMapper::Adapters::PostgresAdapter
        BookingAnalysisQueriesPostgresql.new(repository)
      else
        if DataMapper::Adapters.const_defined?(:MysqlAdapter) and repository.adapter.is_a?DataMapper::Adapters::MysqlAdapter
          BookingAnalysisQueriesMysql.new(repository)
        else
          if DataMapper::Adapters.const_defined?(:SqliteAdapter) and repository.adapter.is_a?DataMapper::Adapters::SqliteAdapter
            BookingAnalysisQueriesSqlite.new(repository)
          end
        end
      end

    end

  end

  BookingDataSystem::Booking.extend(BookingAnalysisQueries)

end