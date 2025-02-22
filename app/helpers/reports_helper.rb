module ReportsHelper
  def report_status_icon(status)
    case status
    when 'pending'
      'fas fa-clock'
    when 'approved'
      'fas fa-check-circle'
    when 'cancelled'
      'fas fa-times-circle'
    when 'completed'
      'fas fa-check-double'
    when 'in_progress'
      'fas fa-spinner'
    else
      'fas fa-question-circle'
    end
  end

  def status_badge_class(status)
    case status
    when 'pending'
      'warning'
    when 'approved'
      'success'
    when 'cancelled'
      'danger'
    when 'completed'
      'info'
    when 'in_progress'
      'primary'
    else
      'secondary'
    end
  end
end 