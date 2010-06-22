class User < Sequel::Model
  plugin :validation_helpers

  Page = "page"
  Post = "post"

  one_to_many :buckets

  def validate
    validates_presence [:username, :password, :key]
    validates_length_range 3..32, :username
    validates_unique(:username, :key)
  end


  def date
    created.strftime "%B %d, %Y"
  end


  def buckets_count
    buckets.count
  end


  def summary(length=300)
    body.gsub(/(<[^>]*>)|\n|\t/s," ")[0..length]
  end

  def update_title(value)

    raise "[ ! ] Could not find title for post" if value.nil?

    self.title = value
    self.name = value.downcase.gsub(/[^\w]/,"_").gsub(/__/,"")
  end
end

class Bucket < Sequel::Model
  plugin :validation_helpers
  many_to_one :users
  one_to_many :objs

  def validate
    validates_presence [:name]
  end

  def date
    created.strftime "%B %d, %Y"
  end

  def user
    User[:id => user_id]
  end

end

class Obj < Sequel::Model
  plugin :validation_helpers
  many_to_one :buckets

  def validate
    validates_presence [:name]
  end

  def bucket
    Bucket[:id => bucket_id]
  end

end

__END__
class Tag < Sequel::Model
  many_to_many :posts, :order => :created.desc
end

class Comment < Sequel::Model
  many_to_one :posts

  def post
    Post[:id => post_id]
  end
end
