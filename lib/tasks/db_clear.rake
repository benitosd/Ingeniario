namespace :db do
  desc "Limpia todos los datos excepto usuarios"
  task clear_all_except_users: :environment do
    puts "Borrando todos los datos excepto usuarios..."
    
    # Desactivar temporalmente las restricciones de clave foránea
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 0") if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
    
    # Lista de modelos a limpiar en orden para evitar problemas de dependencias
    [
      StockMovement,        # Primero los movimientos
      InputReportStock,     # Luego las relaciones de reportes
      OutputReportStock,
      InputReport,          # Después los reportes
      OutputReport,
      ItemLocation,         # Ubicaciones
      Stock,               # Stocks
      Item,                # Items
      Group,               # Grupos
      Family,              # Familias
      Section,             # Secciones
      Warehouse,           # Almacenes
      Unit                 # Unidades
    ].each do |model|
      puts "Borrando #{model.name}..."
      model.delete_all
    end
    
    # Reactivar las restricciones de clave foránea
    ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 1") if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
    
    puts "¡Limpieza completada!"
  end
end 