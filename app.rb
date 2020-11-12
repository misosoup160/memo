# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

configure do
  enable :method_override
end

def openfile
  @comments = File.open('lib/memo.json') do |f|
    JSON.parse(f.read)
  end
end

def dumpfile
  File.open('lib/memo.json', 'w') do |f|
    JSON.dump(@comments, f)
  end
end

def redirect_to_top
  redirect to('/memos')
end

get '/memos' do
  @title = 'memo top'
  openfile
  erb :index
end

get '/memos/new' do
  @title = 'new memo'
  erb :newmemo
end

get '/memos/:id' do
  @title = 'show memo'
  @id = params['id']
  openfile
  erb :showmemo
end

get '/memos/:id/edit' do
  @title = 'edit memo'
  @id = params['id']
  openfile
  @title = @comments[@id.to_i]['title']
  @body = @comments[@id.to_i]['body']
  erb :editmemo
end

post '/memos' do
  unless params['title'].match(/^\s*$/)
    openfile
    @comments << params
    dumpfile
  end
  redirect_to_top
end

delete '/memos/:id' do
  @id = params['id']
  openfile
  @comments.delete_at(@id.to_i)
  dumpfile
  redirect_to_top
end

patch '/memos/:id' do
  @id = params['id']
  openfile
  @comments[@id.to_i]['title'] = params['title']
  @comments[@id.to_i]['body'] = params['body']
  dumpfile
  redirect_to_top
end
