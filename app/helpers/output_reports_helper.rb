module OutputReportsHelper
  def status_badge_class2(status)
    case status
    when 'pending'
      'bg-warning text-dark'
    when 'approved'
      'bg-success text-white'
    when 'rejected'
      'bg-danger text-white'
    else
      'bg-secondary text-white'
    end
  end
end 