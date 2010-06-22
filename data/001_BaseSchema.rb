require 'data/models'

class BaseSchema < Sequel::Migration
  def up
    create_table! :users do
      primary_key :id
      String :username
      String :password
      String :key
      Time :mtime
      Time :created
    end

    create_table! :buckets do
      primary_key :id
      String :name
      foreign_key :user_id, :users
      Time :mtime
      Time :created
    end

    create_table! :obj do
      primary_key :id
      String :name
      String :fileid
      foreign_key :bucket_id, :buckets
      Time :mtime
      Time :created
    end
  end

  def down
    drop_table :users
    drop_table :buckets
    drop_table :files
  end
end
