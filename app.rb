require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require 'sinatra/flash'

enable :sessions

get('/') do

    db = SQLite3::Database.new("db/matcho.db")
    db.results_as_hash = true
    indextable_1 = db.execute("SELECT time_content FROM Time WHERE court_id = 1")
    indextable_2 = db.execute("SELECT court_name FROM Court WHERE court_id = 1")

    slim(:"index",locals:{time_contents:indextable_1, court_contents:indextable_2})
    
end


get('/book') do
    
  db = SQLite3::Database.new("db/matcho.db")
    db.results_as_hash = true
    indextable_1 = db.execute("SELECT time_content FROM Time WHERE court_id = 1")
    indextable_2 = db.execute("SELECT court_name FROM Court WHERE court_id = 1")
    id_time = db.execute("SELECT time_id FROM Time WHERE court_id = 1")
    slim(:"book/start",locals:{time_contents:indextable_1, court_contents:indextable_2, id_time:id_time})
end

get('/book/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/matcho.db")
  court_id = db.execute("SELECT court_id FROM Time WHERE time_id = ?", id).first.first
  db.results_as_hash = true
  indextable_1 = db.execute("SELECT time_content FROM Time WHERE court_id = 1")
  indextable_2 = db.execute("SELECT court_name FROM Court WHERE court_id = 1")
 
 
  result = db.execute("SELECT user_id FROM Court_user_relation WHERE time_id = ?", id)
 if result.length != 0
  user_relation = result.first['user_id']
  booked = db.execute("SELECT username FROM User WHERE user_id = ?", user_relation).first['username']
 end
  slim(:"book/show",locals:{time_contents:indextable_1, court_contents:indextable_2, time_id:id, court_id:court_id, booked:booked})
end

post('/book') do
  username = session[:username]
  db = SQLite3::Database.new("db/Matcho.db")
  db.results_as_hash = true
  user_id = db.execute("SELECT user_id FROM User WHERE username=?", username).first['user_id']
  court_id = params["court_id"]
  time_id = params["time_id"]
  db.execute("INSERT INTO Court_user_relation(court_id, user_id, time_id) VALUES (?,?,?)", court_id, user_id, time_id)
  redirect("/book/#{time_id}")
end

post('/unbook') do
  time_id = params["time_id"]
  db = SQLite3::Database.new("db/Matcho.db")
  db.results_as_hash = true
  db.execute("DELETE FROM Court_user_relation WHERE time_id = ?", time_id)
  redirect("/book/#{time_id}")
end


get('/register') do 
    slim(:"register")

end

post('/register') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    db = SQLite3::Database.new("db/Matcho.db")
    db.results_as_hash = true
    result = db.execute("SELECT user_id FROM User WHERE username=?", username)
     
    if result.empty?
        if password == password_confirm
          pwdigest = BCrypt::Password.create(password)
          db.execute("INSERT INTO User(username, pwdigest) VALUES (?,?)", [username, pwdigest])
         
        p = "Registration succesful"
        redirect('/login')
        else
          p = "Passwords do not match"
          redirect('/register')
        end
    else
      p = "This username already exists. Your username must be unique"
  
      redirect('/register')
    end
  end
  
  get('/login') do
    slim(:login)
  end  
  
  post('/login') do
    username = params[:username]
    password = params[:password]
  
    db = SQLite3::Database.new("db/matcho.db")
    db.results_as_hash = true
    result = db.execute("SELECT user_id, pwdigest FROM User WHERE username=?", [username])
  
    if result.empty?
      p "invalid credentials"
      redirect('/login')
    end
  
    user_id = result.first["user_id"]
    pwdigest = result.first["pwdigest"]
    if BCrypt::Password.new(pwdigest) == password
        session[:user_id] = user_id
        session[:username] = username
  
        p "login succesful"
  
        redirect('/')
    else
      p "invalid credentials"
      redirect('/login')
    end
  end

  post('/logout') do
    session[:user_id] = nil
    session[:username] = nil
    redirect('/')
  end