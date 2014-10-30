require 'google/api_client'
require 'date'
require 'yaml'

config = YAML.load File.open("config.yml")
config = config[:googleanalytics]

# Update these to match your own apps credentials
service_account_email = config[:service_account_email]
key_file = config[:key_file]
key_secret = config[:key_secret]
profiles = config[:profiles]
 
# Get the Google API client
client = Google::APIClient.new(
  :application_name => 'Your app name', 
  :application_version => '0.01'
)
 
points = {}
last_x = {}

# Get back history, if available
profiles.each do |profile|

  points[profile['group']] || points[profile['group']] = {}
  last_x[profile['group']] || last_x[profile['group']] = {}

  history = YAML.load Sinatra::Application.settings.history["ga_rt_active_users_#{profile['group']}"].to_s
  unless history === false
    series_history = history['data']['series'].map{|a| Hash[a.map{|k,v| [k.to_sym,v] }] }
    points[profile['group']][profile['name']] = series_history.find { |h| h[:name] == "#{profile['name']}" }[:data]
    last_x[profile['group']][profile['name']] = points[profile['group']][profile['name']].last['x']
  else
    points[profile['group']][profile['name']] = (0..59).map{|a| { x: a, y: 0 } }
  end

end

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)

# Start the scheduler
SCHEDULER.every '30s', :first_in => 0 do # modified from 1m

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  series = {}

  profiles.each do |profile|

    series[profile['group']] || series[profile['group']] = []

    # Execute the query
    response = client.execute(:api_method => analytics.data.realtime.get, :parameters => {
      'ids' => "ga:" + profile['id'],
      'metrics' => "ga:activeVisitors",
    })

    # Update points list and prepare series
    points[profile['group']][profile['name']].shift
    last_x[profile['group']][profile['name']] += 1
    points[profile['group']][profile['name']] << { x: last_x[profile['group']][profile['name']], y: response.data.rows[0][0].to_i }
    series[profile['group']] << {name: "#{profile['name']}", data: points[profile['group']][profile['name']]}

  end

  series.each do |group,serie|
    # Update the dashboard
    send_event("ga_rt_active_users_#{group}", series: serie)
  end

end
