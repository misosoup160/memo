# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

# configure do
#   enable :method_override
# end

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
  @comment = @comments.select {|comment| comment['id'] == @id }[0]
  @title = @comment['title']
  @body = @comment['body']
  erb :showmemo
end

get '/memos/:id/edit' do
  @title = 'edit memo'
  @id = params['id']
  openfile
  @comment = @comments.select {|comment| comment['id'] == @id }[0]
  @title = @comment['title']
  @body = @comment['body']
  erb :editmemo
end

post '/memos' do
  unless params['title'].match(/^\s*$/)
    openfile
    memodata = {
      id: SecureRandom.uuid,
      title: params['title'],
      body: params['body']
    }
    @comments << memodata
    dumpfile
  end
  redirect_to_top
end

delete '/memos/:id' do
  @id = params['id']
  openfile
  @comments.delete_if { |comment| comment['id'] == @id }
  dumpfile
  redirect_to_top
end

patch '/memos/:id' do
  @id = params['id']
  openfile
  @comment = @comments.select {|comment| comment['id'] == @id }[0]
  @comment['title'] = params['title']
  @comment['body'] = params['body']
  dumpfile
  redirect_to_top
end
