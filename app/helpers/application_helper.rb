module ApplicationHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ActionView::Helpers::TextHelper

  def errors_for(object)
    return unless object.errors.any?
    content_tag :div, class:'error-explanation center-block panel panel-danger' do
      concat(content_tag(:div, class: 'panel-heading') do
        content_tag :h2, class: 'panel-title' do
          title = 'There'
          if object.errors.count == 1
            title << " is #{object.errors.count} error"
          else
            title << " are #{object.errors.count} errors"
          end
          title << ' prohibited this '+ object.model_name.human.downcase + ' from being created'
        end
      end)

      concat(content_tag(:table, class: 'table') do
        object.errors.full_messages.each do |msg|
          concat(raw('<tr><td>' + msg + '</td></tr>'))
        end
      end)
    end
  end
end
