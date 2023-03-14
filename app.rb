require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

get('/') do

    db = SQLite3::Database.new("db/matcho.db")
    db.results_as_hash = true
    #id = params[:id].to_i
    indextable_1 = db.execute("SELECT time_content FROM Time WHERE court_id = 1")
    indextable_2 = db.execute("SELECT courtname FROM Court WHERE court_id = 1")

    p result
    slim(:"index",locals:{time_contents:indextable_1,time_contents:indextable_2})
    
end


