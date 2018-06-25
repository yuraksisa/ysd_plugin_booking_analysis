module Sinatra
  module YitoExtension
    module BookingAnalysis
      def self.registered(app)

        app.settings.views = Array(app.settings.views).push(
            File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                       'views')))
        app.settings.translations = Array(app.settings.translations).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'i18n')))

        #
        # renting booking summary
        #
        app.route :get, :post, ['/admin/booking/analysis/summary'], :allowed_usergroups => ['booking_manager', 'staff'] do

          @today = Date.today
          @from = Date.civil(@today.year, 1, 1)
          @to = Date.civil(@today.year,12,31)#@today
          @previous_year_first_day = Date.civil(@today.year-1,1,1)
          @previous_year_last_day = Date.civil(@today.year-1,12,31)
          @before_previous_year_first_day = Date.civil(@today.year-2,1,1)
          @before_previous_year_last_day = Date.civil(@today.year-2,12,31)

          @cummulative_reservation_data = BookingDataSystem::Booking.booking_cummulative_received_reservations(@from, @to)
          @cummulative_reservation_data_previous = BookingDataSystem::Booking.booking_cummulative_received_reservations(@previous_year_first_day, @previous_year_last_day)
          @cummulative_reservation_data_before_previous = BookingDataSystem::Booking.booking_cummulative_received_reservations(@before_previous_year_first_day, @before_previous_year_last_day)

          load_page(:renting_summary)
        end

        #
        # Renting analysis
        #
        app.route :get, :post, ['/admin/booking/analysis/renting'], :allowed_usergroups => ['booking_manager', 'staff'] do

          if request.post?
            @received_from = parse_date(params['received_from'], session[:locale])
            @received_to = parse_date(params['received_to'], session[:locale])
            @reservation_start_from = parse_date(params['reservation_start_from'], session[:locale])
            @reservation_start_to = parse_date(params['reservation_start_to'], session[:locale])

            @result = BookingDataSystem::Booking.booking_received_reservations(@received_from,
                                                                               @received_to,
                                                                               @reservation_start_from,
                                                                               @reservation_start_to)

            @result_previous_year = BookingDataSystem::Booking.booking_received_reservations(@received_from<<(12),
                                                                                             @received_to<<(12),
                                                                                             @reservation_start_from<<(12),
                                                                                             @reservation_start_to<<(12))
            p "result: #{@result.inspect} previous: #{@result_previous_year.inspect}"


          end

          load_page (:renting_analysis)

        end

      end
    end
  end
end