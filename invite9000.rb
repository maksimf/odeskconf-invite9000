require 'sinatra'
require 'rest-client'
require 'json'
require 'pry'

SLACK_URL = ENV['SLACK_URL']

get '/' do
  erb :index
end

get '/thanks' do
  erb :thanks
end

post '/register' do
  payload = {
    "text" => "*Почта:* #{params['email']}\n" \
              "*Откуда узнал про конфу?:* #{params['heardFrom']}\n" \
              "*Пара слов о себе:* #{params['about']}",
    "replace_original" => false,
    "delete_original" => false,          
    "attachments" => [
      {
        "fallback" => "Не удалось отправить запрос",
        "callback_id" => "inviter",
        "attachment_type" => "default",
        "actions" => [
          {
            "name" => params['email'],
            "text" => "Пригласить",
            "type" => "button",
            "value" => "accept",
            "style" => "primary",
          },
          {
            "name" => params['email'],
            "text" => "Отказать",
            "type" => "button",
            "value" => "decline",
            "style" => "danger",
          }
        ]
      }
    ]
  }
  RestClient.post(SLACK_URL, payload.to_json, 'Content-Type' => 'application/json')

  erb :thanks
end

post '/invite' do
  payload = JSON.parse(URI.decode_www_form(request.body.read)[0][1])
  email = payload['actions'][0]['name']
  action = payload['actions'][0]['value']
  url_params = URI.encode_www_form([['token', ENV['SLACK_TOKEN']], ['email', email]])
  url = "https://slack.com/api/users.admin.invite?#{url_params}"

  halt 401 unless ENV['SLACK_VERIFICATION'] == payload['token']
  halt 200, ":x: Юзеру с почтой #{email} отказано" if action == 'decline'

  RestClient.post(url, '')

  halt 200, ":white_check_mark: Юзер с почтой #{email} приглашён"
end
