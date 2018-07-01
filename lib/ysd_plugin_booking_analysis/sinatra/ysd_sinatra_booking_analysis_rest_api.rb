module Sinatra
  module YitoExtension
    module BookingAnalysisRESTApi
      def self.registered(app)

        #
        # Yearly reservations group by month
        #
        app.get '/api/booking/analysis/reservations', :allowed_usergroups => ['booking_manager', 'staff']  do

          year = params[:year] || Date.today.year
          previous_year = year.to_i - 1

          confirmed_year = BookingDataSystem::Booking.reservations_confirmed_by_reservation_date(year)
          confirmed_previous_year = BookingDataSystem::Booking.reservations_confirmed_by_reservation_date(previous_year)

          result = {}

          (1..12).each do |element|
            period = element
            result.store(period, {confirmed_previous_year: 0, confirmed: 0})
          end

          confirmed_year.each do |item|
            result.fetch(item.period.split('-').last.to_i).store(:confirmed, item.occurrences)
          end

          confirmed_previous_year.each do |item|
            result.fetch(item.period.split('-').last.to_i).store(:confirmed_previous_year, item.occurrences)
          end

          result.to_json

        end

        #
        # Yearly invocing group by month
        #
        app.get '/api/booking/analysis/invoicing', :allowed_usergroups => ['booking_manager', 'staff']  do

          year = params[:year] || Date.today.year
          previous_year = year.to_i - 1

          data = BookingDataSystem::Booking.incoming_money_summary(year)
          data_previous_year = BookingDataSystem::Booking.incoming_money_summary(previous_year)

          result = {}

          (1..12).each do |element|
            period = element
            result.store(period, {total: 0, total_previous_year: 0})
          end

          data.each do |item|
            result.fetch(item.period.split('-').last.to_i).store(:total, sprintf("%.2f", item.total))
          end

          data_previous_year.each do |item|
            result.fetch(item.period.split('-').last.to_i).store(:total_previous_year, sprintf("%.2f", item.total))
          end

          result.to_json

        end

        app.get '/api/booking/analysis/invoicing-products', :allowed_usergroups => ['booking_manager', 'staff']  do

          year = params[:year] || Date.today.year
          year = year.to_i
          previous_year = year.to_i - 1

          data = BookingDataSystem::Booking.invoicing_by_product_category(year)
          data_previous_year = BookingDataSystem::Booking.invoicing_by_product_category(previous_year)

          result = data.inject({}) do |result, item|
                       result[item.item_id] = {total: item.total, total_previous_year: 0}
                       result
                   end

          data_previous_year.each do |item|
            result[item.item_id][:total_previous_year] = item.total if result.has_key?(item.item_id)
          end

          result.to_json

        end


        #
        # Invoicing by sales_channel
        #
        app.get '/api/booking/analysis/invoicing-sales-channel', :allowed_usergroups => ['booking_manager', 'staff']  do

          year = params[:year] || Date.today.year
          previous_year = year.to_i - 1

          sales_channels = ::Yito::Model::SalesChannel::SalesChannel.all.map {|sc| sc.code}
          sales_channels_codes = sales_channels.inject({default: 0, total: 0, default_previous_year: 0, total_previous_year: 0}) do |result, item|
                                   result.store(item.to_sym, 0)
                                   result.store("#{item}_previous_year".to_sym, 0)
                                   result
                                 end

          data = BookingDataSystem::Booking.invoicing_by_sales_channel(year)
          data_previous_year = BookingDataSystem::Booking.invoicing_by_sales_channel(previous_year)

          result = {}

          (1..12).each do |element|
            period = element
            result.store(period, sales_channels_codes.clone)
          end

          data.each do |item|
            period = item.period.split('-').last.to_i
            sales_channel = if item.sales_channel_code.nil? or item.sales_channel_code.empty?
                             :default
                            else
                              item.sales_channel_code.to_sym
                            end
            result[period][sales_channel] += item.total
            result[period][:total] += item.total
          end

          data_previous_year.each do |item|
            period = item.period.split('-').last.to_i
            sales_channel = if item.sales_channel_code.nil? or item.sales_channel_code.empty?
                              :default_previous_year
                            else
                              "#{item.sales_channel_code}_previous_year".to_sym
                            end
            result[period][sales_channel] += item.total
            result[period][:total_previous_year] += item.total
          end


          result.to_json

        end

        # ---------------------------------------------------------------------------------------------------------

        #
        # Yearly received and confirmed reservations group by month
        #
        app.get '/api/booking/analysis/received-reservations', :allowed_usergroups => ['booking_manager', 'staff']  do

          year = params[:year] || Date.today.year

          received = BookingDataSystem::Booking.reservations_received_by_creation_date(year)
          confirmed = BookingDataSystem::Booking.reservations_confirmed_by_creation_date(year)

          result = {}

          (1..12).each do |element|
            period = "#{year}-#{element.to_s.rjust(2, '0')}"
            result.store(period, {requests: 0, confirmed: 0})
          end

          received.each do |item|
            result.store(item.period, :requests => item.occurrences, :confirmed => 0)
          end

          confirmed.each do |item|
            result.fetch(item.period).store(:confirmed, item.occurrences)
          end

          result.to_json

        end

      end
    end
  end
end