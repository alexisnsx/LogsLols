module ApplicationHelper
  def icon_tag(reminder_bell)
    content_tag(:i, '', class: "icon-#{reminder_bell}")
  end

end
