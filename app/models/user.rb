class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable
  searchable do
    string :code
    string :email
  end
  def has_directive?(directive)
    return false if self.directive.nil?
    (self.directive & directive) != 0
  end
end
