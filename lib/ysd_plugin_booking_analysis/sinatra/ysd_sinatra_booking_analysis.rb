module Sinatra
  module YitoExtension
    module BookingAnalysis
      def self.registered(app)

        app.settings.views = Array(app.settings.views).push(
            File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                       'views')))
        app.settings.translations = Array(app.settings.translations).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'i18n')))

        #
        # Renting analysis
        #
        app.route :get, :post, ['/admin/booking/analysis/renting', '/admin/booking/analysis/renting'], :allowed_usergroups => ['booking_manager', 'staff'] do

          if request.post?
            @received_from = parse_date(params['received_from'], session[:locale])
            @received_to = parse_date(params['received_to'], session[:locale])
            @reservation_start_from = parse_date(params['reservation_start_from'], session[:locale])
            @reservation_start_to = parse_date(params['reservation_start_to'], session[:locale])

            @result = BookingDataSystem::Booking.booking_received_reservations(@received_from,
                                                                               @received_to,
                                                                               @reservation_start_from,
                                                                               @reservation_start_to)

            @result_previous_year = BookingDataSystem::Booking.booking_received_reservations(@received_from<<(1),
                                                                                             @received_to<<(1),
                                                                                             @reservation_start_from<<(1),
                                                                                             @reservation_start_to<<(1))
          end

          load_page (:renting_analysis)

        end

      end
    end
  end
end