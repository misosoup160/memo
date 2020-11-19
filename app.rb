# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

def new_data(params)
  title = params['title']
  body = params['body']
  sql = 'INSERT INTO Memos (memo_title, memo_body) VALUES ($1, $2)'
  connect_data(sql, [title, body])
end

def select_data(id)
  sql = 'SELECT * FROM Memos WHERE memo_id = $1'
  connect_data(sql, [id])
  @memo = @memos[0]
end

def edit_data(id)
  title = params['title']
  body = params['body']
  sql = 'UPDATE Memos SET memo_title = $1, memo_body = $2 WHERE memo_id = $3'
  connect_data(sql, [title, body, id])
end

def delete_data(id)
  sql = 'DELETE FROM Memos WHERE memo_id = $1'
  connect_data(sql, [id])
end

def connect_data(sql, values = nil)
  connect = PG.connect(host: 'localhost', user: 'postgres', password: '', dbname: 'memoapp', port: '5432')
  if sql.include?('SELECT')
    @memos = connect.exec(sql, values)
  else
    connect.exec(sql, values)
  end
  connect.finish
end

def redirect_to_top
  redirect to('/memos')
end

get '/' do
  redirect_to_top
end

get '/memos' do
  @title = 'memo top'
  sql = 'SELECT * FROM Memos'
  connect_data(sql)
  erb :index
end

get '/memos/new' do
  @title = 'new memo'
  erb :newmemo
end

get '/memos/:id' do
  @title = 'show memo'
  id = params['id']
  select_data(id)
  return 404 if @memos.values.empty? 

  erb :showmemo
end

get '/memos/:id/edit' do
  @title = 'edit memo'
  id = params['id']
  select_data(id)
  return 404 if @memos.values.empty?

  erb :editmemo
end

post '/memos' do
  new_data(params) unless params['title'].match(/^\s*$/)
  redirect_to_top
end

delete '/memos/:id' do
  id = params['id']
  delete_data(id)
  redirect_to_top
end

patch '/memos/:id' do
  id = params['id']
  edit_data(id) unless params['title'].match(/^\s*$/)
  redirect_to_top
end
