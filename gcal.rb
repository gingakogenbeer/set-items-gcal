#!/usr/bin/env ruby
require "google/apis/calendar_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "date"
require "fileutils"

class GCalendar
  def initialize
    @OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
    @APPLICATION_NAME = "Google Calendar API Ruby Quickstart".freeze
    @CREDENTIALS_PATH = "credentials.json".freeze
    @TOKEN_PATH = "token.yaml".freeze
    @SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = @APPLICATION_NAME
    @service.authorization = authorize
  end

  def authorize
    client_id = Google::Auth::ClientId.from_file @CREDENTIALS_PATH
    token_store = Google::Auth::Stores::FileTokenStore.new file: @TOKEN_PATH
    authorizer = Google::Auth::UserAuthorizer.new client_id, @SCOPE, token_store
    user_id = "default"
    credentials = authorizer.get_credentials user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: @OOB_URI
      puts "Open the following URL in the browser and enter the " \
          "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: @OOB_URI
      )
    end
    return credentials
  end

  def setCal(title, startdate, enddate, location)
    event = Google::Apis::CalendarV3::Event.new(
      summary: title,
      location: location,
      description: 'my event',
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: startdate,
        time_zone: 'Asia/Tokyo'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: enddate,
        time_zone: 'Asia/Tokyo'
      ),
      recurrence: [
        'RRULE:FREQ=DAILY;COUNT=1'
      ],
      #attendees: [
      #  Google::Apis::CalendarV3::EventAttendee.new(
      #    email: ''
      #  ),
      reminders: Google::Apis::CalendarV3::Event::Reminders.new(
        use_default: false,
        overrides: [
          Google::Apis::CalendarV3::EventReminder.new(
            reminder_method: 'email',
            minutes: 24 * 60
          ),
          Google::Apis::CalendarV3::EventReminder.new(
            reminder_method: 'popup',
            minutes: 30
          )
        ]
      )
    )
    result = @service.insert_event('primary', event)
  end
end