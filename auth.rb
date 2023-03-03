require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'googleauth/stores/file_token_store'
require 'sinatra'
require 'pry'
require 'net/http'
require 'uri'
require 'json'

enable :sessions

client_id = Google::Auth::ClientId.from_file('./client_secrets.json')
token_store = Google::Auth::Stores::FileTokenStore.new(
  file: './tokens.yaml'
)
scope = ['https://www.googleapis.com/auth/photoslibrary.readonly']
authorizer = Google::Auth::WebUserAuthorizer.new(
  client_id, scope, token_store, '/oauth2callback'
)

get('/authorize') do
  # NOTE: Assumes the user is already authenticated to the app
  user_id = 'rene@weteling.com'
  credentials = authorizer.get_credentials(user_id, request)
  redirect authorizer.get_authorization_url(login_hint: user_id, request: request) if credentials.nil?

  sync(credentials.access_token)
  'done'
end

get('/oauth2callback') do
  target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(
    request
  )
  redirect target_url
end


def sync(token)
  nextPageToken = nil
  idx = 0
  while idx == 0 || nextPageToken != nil do
    idx +=1
    fetch("mediaItems?pageSize=100&pageToken=#{nextPageToken}", token) => {mediaItems:, nextPageToken:}

    data = mediaItems.map do |item|
      item => {filename:, mediaMetadata: {creationTime:}}
      "#{creationTime}, #{filename}\n" 
    end
    .join()

    File.write("pictures.csv", data, mode: "a")
    puts 
  end
end

def fetch(path, token)
  uri = URI.parse("https://photoslibrary.googleapis.com/v1/#{path}")

  request = Net::HTTP::Get.new(uri)
  request['Accept'] = 'application/json'
  request['Authorization'] = "Bearer #{token}"

  pp request['Authorization']

  req_options = {
    use_ssl: uri.scheme == 'https'
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  data = JSON.parse(response.body, {:symbolize_names => true})

  pp data

  data
end
