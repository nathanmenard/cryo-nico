module ApplicationHelper
  def day_in_french(day_in_english)
    case day_in_english
    when 'Monday'
      return 'Lundi'
    when 'Tuesday'
      return 'Mardi'
    when 'Wednesday'
      return 'Mercredi'
    when 'Thursday'
      return 'Jeudi'
    when 'Friday'
      return 'Vendredi'
    when 'Saturday'
      return 'Samedi'
    end
    day_in_english
  end

  def month_in_french(month_in_english)
    case month_in_english
    when 'January'
      return 'Janvier'
    when 'February'
      return 'Fevrier'
    when 'March'
      return 'Mars'
    when 'April'
      return 'Avril'
    when 'May'
      return 'Mai'
    when 'June'
      return 'Juin'
    when 'July'
      return 'Juillet'
    when 'August'
      return 'Août'
    when 'September'
      return 'Septembre'
    when 'October'
      return 'Octobre'
    when 'November'
      return 'Novembre'
    when 'December'
      return 'Décembre'
    end
    month_in_english
  end
end
