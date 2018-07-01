module Sinatra
  module YitoExtension
    module BookingAnalysis
      def self.registered(app)

        app.settings.views = Array(app.settings.views).push(
            File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                       'views')))
        app.settings.translations = Array(app.settings.translations).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'i18n')))

        #
        # Monthly - Yearly summary
        #
        app.get '/admin/booking/analysis/summary', :allowed_usergroups => ['booking_manager', 'staff'] do

          first = BookingDataSystem::Booking.first(order: :creation_date.asc, limit: 1)
          first_year = first ? first.creation_date.year : Date.today.year
          current_year = Date.today.year

          # Sales channels
          addons = mybooking_addons
          @addon_sales_channels = (addons and addons.has_key?(:addon_sales_channels) and addons[:addon_sales_channels])
          if @addon_sales_channels
            @sales_channels_count = ::Yito::Model::SalesChannel::SalesChannel.count + 1
            @sales_channels = [{code: 'default',fillColor: 'rgba(151,187,205,0.5)',
                                strokeColor: 'rgba(151,187,205,1)'}].concat(::Yito::Model::SalesChannel::SalesChannel.all.map { |sc| {code: sc.code, fillColor: sc.color,
                                                                                                           strokeColor: sc.color} })
            p "sales_channels:#{@sales_channels}"
          end

          load_page(:booking_analysis_summary, :locals => {first_year: first_year, current_year: current_year})
        end

        #
        # Received reservations PLOT
        #
        app.route :get, :post, ['/admin/booking/analysis/received-reservations'], :allowed_usergroups => ['booking_manager', 'staff'] do

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

          first = BookingDataSystem::Booking.first(order: :creation_date.asc, limit: 1)
          first_year = first ? first.creation_date.year : Date.today.year
          current_year = Date.today.year

          load_page(:received_reservations, locals: {current_year: current_year, first_year: first_year})
        end

        #
        # User selected periods analysis
        #
        app.route :get, :post, ['/admin/booking/analysis/periods'], :allowed_usergroups => ['booking_manager', 'staff'] do

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

          end

          load_page (:renting_analysis)

        end


      end
    end
  end
end