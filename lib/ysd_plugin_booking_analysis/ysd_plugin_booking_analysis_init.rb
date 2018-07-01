require 'ysd-plugins' unless defined?Plugins::Plugin

Plugins::SinatraAppPlugin.register :booking_analysis do

  name=        'booking_analysis'
  author=      'yurak sisa'
  description= 'Booking analysis'
  version=     '0.1'
  hooker       YsdPluginBookingAnalysis::BookingAnalysisExtension
  sinatra_extension Sinatra::YitoExtension::BookingAnalysis
  sinatra_extension Sinatra::YitoExtension::BookingAnalysisRESTApi

end