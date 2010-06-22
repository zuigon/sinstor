require "rubygems"
require "sinatra"
require "haml"
require 'sequel'
require 'mongo'
require 'active_support/secure_random'
# include Mongo
# configure do
  # db = Connection.new.db('sinstordb')
  # users = db.collection('users')
  # buckets = db.collection('buckets')
# end

db = Sequel.connect "sqlite://db.sqlite"

require "data/models"


def auth?(name, key)
  if user = User.find(:username => name, :key => key)
    @user = user
    return true
  end
  return false
end


get '/auth' do
  name, key, out = params[:name], params[:key], ''
  if !name.nil? && !key.nil?
    if auth?(params[:name], params[:key])
      @out = "Logged in!"
    else
      @out = "Wrong username/key!"
    end
  else
    @out = "Not logged in!"
  end
  @out = @out+'<br />'+'Your password: '+( (@user)?(@user.password):'' )
  haml :auth
end


get '/' do
  "<h3>welcome to SinatraCloudStorageApp; staging ...</h3>"
end

get '/register/user/:username' do |n|
  # users.insert( {"user" => n} )
  key = ActiveSupport::SecureRandom.hex(16)
  user = User.new(
    :username => n,
    :password => (params[:pw] || 'temppw'),
    :key => key
  )
  begin
    user.save
  rescue Exception => e
    return 'error: ' + e
    # return 'error: ' + user.errors.full_messages.join('<br />')
  end

  return 'user created: '+user.username+'<br />'+'key: '+user.key

end

get '/list' do
  out = 'User count: ' + User.count.to_s
  out+= '<pre>'
  # out+= User.all #.inspect
  out+= '</pre>'
  out+= 'Lista: <br />'
  User.all.each { |u|
    out += u.username + ':' + u.password + ':' + u.key + '<br />' + '- buckets:'
    u.buckets.each { |b|
      '- '+'name: '+b.name+' - files: <br />'
      b.objs.each { |o|
        '- FILE '+'name: '+o.name+'<br />'
      }
    }
    out+='<br />'
  }
  # User.all.each { |row| out += row.username + ':' + row.password + '<br />' }
  return out
end

get '/files/:file' do |file|
  file = File.join('./files', file)
  send_file(file, :disposition => 'attachment', :filename => File.basename(file))
end


get '/new/:user' do |user| # new bucket

  begin
    user = User.find(:username => user)
  rescue Exception => e
    return 'error: ' + e.to_s + ' .. ' + user.errors.full_messages.join('<br />')
  end

  begin
    bucket = Bucket.new(:name => params[:bucket_name], :user_id => user.id)
    bucket.save
  rescue Exception => e
    return 'error: ' + e.to_s + ' .. ' + bucket.errors.full_messages.join('<br />')
  end

end

get '/new/:user/:bucket' do |user, bucket| # new object/file
  # lista datoteka i forma za upload u taj bucket
end


__END__

@@ layout
!!! Strict
%html
  %head
    %title SinatraStoreApp
    %meta{"http-equiv"=>"Content-Type", :content=>"text/html; charset=utf-8"}/
    //= "<style type='text/css'>#{css}</style>"

  %body
    #container
      //- if authorized?
      //  %p.logout
      //    %a(href="/logout") Logout
      %br
      = yield
      %br


@@ auth
= @out


# @@ list_users
# %h2= "NAT Rules (za #{@router})"
# #list
#   - @rules.each do |rule|
#     %h3.title
#       - rule_id = rule[0]
#       %a{:href=>"/del?id=#{rule_id}"} [DEL]
#       = "#{rule_id}: #{if rule[1]["desc"]!=""; rule[1]["desc"] else; "<i>untitled</i>" end}"
#     %p= "0.0.0.0:#{rule[1]["port_sa"]||rule[1]["port"]} -> #{rule[1]["host"]}:#{rule[1]["port_na"]||rule[1]["port"]}"
#   %font{"size"=>"+2"}
#     %a{btn_pri} Primjeni
#     |
#     %a{btn_dod} Dodaj


