class ChangeStatusTypeInInputReports < ActiveRecord::Migration[7.0]
  def up
    change_column :input_reports, :status, :string, default: 'pending'
    
    # Actualizar los registros existentes
    execute <<-SQL
      UPDATE input_reports 
      SET status = CASE status::integer
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'approved'
        WHEN 2 THEN 'cancelled'
      END;
    SQL
  end

  def down
    execute <<-SQL
      UPDATE input_reports 
      SET status = CASE status
        WHEN 'pending' THEN '0'
        WHEN 'approved' THEN '1'
        WHEN 'cancelled' THEN '2'
      END;
    SQL
    
    change_column :input_reports, :status, :integer, default: 0
  end
end 