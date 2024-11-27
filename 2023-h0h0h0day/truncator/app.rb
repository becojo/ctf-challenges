# frozen_string_literal: true

require 'sinatra'
require 'html_truncator' # https://github.com/nono/HTML-Truncator/tree/245ba6fc17ff7e95611b10e157e3c5a3e8ad576c

SOURCE = File.read(__FILE__)

error do
  @error = env['sinatra.error']
  @error.to_s
end

get '/' do
  erb :index
end

post '/truncate' do
  html = params[:html]
  options = { ellipsis: '', length_in_chars: false, length: params[:length] }

  params[:options] ||= {}
  params[:options].each do |option, _|
    options.merge!(JSON.parse(option, symbolize_names: true))
  end

  @html = HTML_Truncator.truncate(html, options[:length].to_i, options)

  erb :index
end

get '/source' do
  content_type 'text/plain'
  SOURCE
end
