class AddEducationToJobs < ActiveRecord::Migration[5.1]
  def change
  	add_column :jobs, :educationLevel, :string
  end
end
