module ApplicationHelper

  def iconlink(id, css_class, ng_click)
    render partial: "shared/iconlink", locals: {
      id: id,
      css_class: css_class,
      ng_click: ng_click
    }
  end

end
