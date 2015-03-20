class MakeAccountTypeIndexInUsers < ActiveRecord::Migration
  def change
    add_index :users, :account_type # Easily the most requested resource.
  end
end
