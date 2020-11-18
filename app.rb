# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

def set_data(params)
  openfile
    memodata = {
      id: SecureRandom.uuid,
      title: params['title'],
      body: params['body']
    }
    @comments << memodata
    dumpfile
end

def select_data(id)
  openfile
  @comment = @comments.select {|comment| comment['id'] == @id }[0]
  @title = @comment['title']
  @body = @comment['body']
end

def edit_data(id)
  openfile
  @comment = @comments.select {|comment| comment['id'] == id }[0]
  @comment['title'] = params['title']
  @comment['body'] = params['body']
  dumpfile
end

def delete_data(id)
  openfile
  @comments.delete_if { |comment| comment['id'] == id }
  dumpfile
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
  select_data(@id)
  erb :showmemo
end

get '/memos/:id/edit' do
  @title = 'edit memo'
  @id = params['id']
  select_data(@id)
  erb :editmemo
end

post '/memos' do
  unless params['title'].match(/^\s*$/)
    set_data(params)
  end
  redirect_to_top
end

delete '/memos/:id' do
  @id = params['id']
  delete_data(@id)
  redirect_to_top
end

patch '/memos/:id' do
  @id = params['id']
  edit_data(@id)
  redirect_to_top
end
