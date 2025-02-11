class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :materials, dependent: :destroy
  has_many :manufacturing_processes, dependent: :destroy
  has_many :extras, dependent: :destroy
  has_many :units, dependent: :destroy
  has_many :unit_equivalences, dependent: :destroy
  has_many :general_configurations, dependent: :destroy
  has_many :quotes, dependent: :destroy
  has_many :manufacturing_processes
  has_many :app_settings

  after_create :setup_initial_data

  def admin?
    # Implement your admin check logic here
    # For example: role == 'admin' or admin == true
  end

  private

  def setup_initial_data
    UserSetupService.new(self).setup_initial_data
  end
end
