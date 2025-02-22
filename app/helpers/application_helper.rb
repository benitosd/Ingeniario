module ApplicationHelper
    def flash_class(type)
        case type
        when 'notice' then 'alert-success'
        when 'success' then 'alert-success'
        when 'error' then 'alert-danger'
        when 'alert' then 'alert-warning'
        else 'alert-info'
        end
    end    

    def status_badge_class(status)
        case status
        when 'pending'
            'bg-warning'
        when 'approved'
            'bg-success'
        when 'cancelled'
            'bg-danger'
        else
            'bg-secondary'
        end
    end
end
