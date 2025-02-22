# app/helpers/stocks_helper.rb
module StocksHelper
    def qr_code_tag(stock, size: :medium)
      sizes = {
        small: 150,
        medium: 250,
        large: 400
      }
      
      content_tag :div, class: "qr-code qr-code-#{size}" do
        raw stock.generate_qr_code_svg
      end
    end

    def status_badge_class(status)
      case status.to_s
      when 'entrada'
        'badge-info'
      when 'in_storage'
        'badge-success'
      when 'assigned'
        'badge-primary'
      when 'en_reparacion'
        'badge-warning'
      when 'roto'
        'badge-danger'
      when 'desaparecido'
        'badge-danger'
      when 'pending'
        'badge-secondary'
      when 'approved'
        'badge-success'
      when 'cancelled'
        'badge-danger'
      else
        'badge-secondary'
      end
    end

    def movement_status_class(status)
      case status.to_s
      when 'entrada'
        'bg-info'
      when 'in_storage'
        'bg-success'
      when 'assigned'
        'bg-primary'
      when 'en_reparacion'
        'bg-warning'
      when 'roto', 'desaparecido'
        'bg-danger'
      when 'pending'
        'bg-secondary'
      when 'approved'
        'bg-success'
      when 'cancelled'
        'bg-danger'
      else
        'bg-secondary'
      end
    end

    def stock_status_icon(status)
      case status.to_s
      when 'entrada'
        'fas fa-inbox'
      when 'in_storage'
        'fas fa-warehouse'
      when 'assigned'
        'fas fa-user-check'
      when 'en_reparacion'
        'fas fa-tools'
      when 'roto'
        'fas fa-ban'
      when 'desaparecido'
        'fas fa-question-circle'
      else
        'fas fa-circle'
      end
    end

    def stock_action_buttons(stock)
      buttons = []
      
      if stock.can_be_assigned?
        buttons << link_to(new_output_report_path(stock_id: stock.id), 
                          class: 'btn btn-sm btn-primary') do
          content_tag(:i, '', class: 'fas fa-share') + ' Asignar'
        end
      end

      if stock.can_be_repaired?
        buttons << button_to(repair_stock_path(stock),
                           method: :patch,
                           class: 'btn btn-sm btn-warning',
                           data: { confirm: '¿Enviar a reparación?' }) do
          content_tag(:i, '', class: 'fas fa-tools') + ' Reparar'
        end
      end

      if stock.in_repair?
        buttons << button_to(mark_as_broken_stock_path(stock),
                           method: :patch,
                           class: 'btn btn-sm btn-danger',
                           data: { confirm: '¿Marcar como roto?' }) do
          content_tag(:i, '', class: 'fas fa-ban') + ' Marcar Roto'
        end
      end

      if stock.assigned?
        buttons << button_to(mark_as_missing_stock_path(stock),
                           method: :patch,
                           class: 'btn btn-sm btn-danger',
                           data: { confirm: '¿Marcar como desaparecido?' }) do
          content_tag(:i, '', class: 'fas fa-question-circle') + ' Marcar Desaparecido'
        end
      end

      safe_join(buttons, ' ')
    end

    # Alias para mantener compatibilidad con el partial
    def status_icon(status)
      stock_status_icon(status)
    end
end