require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'

get('/') do

    db = SQLite3::Database.new("db/matcho.db")
    db.results_as_hash = true
    id = params[:id].to_i
    indextable_1 = db.execute("SELECT time_content FROM Time WHERE court_id = 1")
    indextable_2 = db.execute("SELECT court_name FROM Court WHERE court_id = 1")

    slim(:"index",locals:{time_contents:indextable_1, court_contents:indextable_2})
    
end


get('/book/:id') do
    

end

get('/sign_up') do
    slim(:sign_up)

end

post('/sign_up') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    result = db.execute("SELECT user_id FROM User WHERE username=?", username)
     
    if result.empty?
        if password == password_confirm
          password_digest = BCrypt::Password.create(password)
          p password_digest
          db.execute("INSERT INTO User(username, password_digest) VALUES (?,?)", [username, password_digest])
         
        flash[:notice] = "Registration done succesfully"
        redirect('/')
        else
          flash[:warning] = "Passwords do not match"
  
          redirect('/sign_up')
        end
    else
      flash[:warning] = "This username already exists. Your username must be unique"
  
      redirect('/sign_up')
    end
  end
  
  get('/login') do
    slim(:login)
  end  
  
  post('/login') do
    username = params[:username]
    password = params[:password]
  
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    result = db.execute("SELECT user_id, password_digest FROM User WHERE username=?", [username])
  
    if result.empty?
      session[:alert] = "Invalid credentials"
      redirect('/login')
    end
  
    user_id = result.first["user_id"]
    password_digest = result.first["password_digest"]
    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = user_id
        session[:username] = username
  
        session[:alert] = "Login succesful"
  
        redirect('/')
    else
      session[:alert] = "Invalid credentials"
      redirect('/login')
    end
  end