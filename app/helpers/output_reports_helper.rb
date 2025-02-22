module OutputReportsHelper
  def status_badge_class(status)
    case status.to_s
    when 'pending'
      'warning'
    when 'approved'
      'success'
    when 'rejected'
      'danger'
    else
      'secondary'
    end
  end
end 