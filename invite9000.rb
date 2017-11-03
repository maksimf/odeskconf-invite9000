require 'sinatra'
require 'rest-client'
require 'json'

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
    "attachments" => [
      {
        "fallback" => "Не удалось отправить запрос",
        "callback_id" => "inviter",
        "attachment_type" => "default",
        "actions" => [
          {
            "name" => "invite",
            "text" => "Пригласить",
            "type" => "button",
            "value" => "invite",
            "style" => "primary"
          },
          {
            "name" => "invite",
            "text" => "Отказать",
            "type" => "button",
            "value" => "decline",
            "style" => "danger"
          }
        ]
      }
    ]
  }
  RestClient.post(SLACK_URL, payload.to_json, 'Content-Type' => 'application/json')

  erb :thanks
end

post '/invite' do
end
