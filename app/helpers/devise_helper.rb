module DeviseHelper
  def devise_error_messages!
    flash_alerts = []
        error_key = 'errors.messages.not_saved'

        if flash.present?
          flash_alerts.push(flash[:error]) if flash[:error]
          flash_alerts.push(flash[:alert]) if flash[:alert]
          flash_alerts.push(flash[:notice]) if flash[:notice]
          error_key = 'devise.failure.invalid'
        end

        return "" if resource.errors.empty? && flash_alerts.empty?
        errors = resource.errors.empty? ? flash_alerts : resource.errors.values.flatten
        messages = errors.map { |msg| content_tag(:li, msg) }.join
        sentence = I18n.t(error_key, :count    => errors.count,
                                     :resource => resource.class.model_name.human.downcase)
        html = <<-HTML
        <div id="error_explanation">
          <ul>#{messages}</ul>
        </div>
        HTML

        html.html_safe
  end

  def devise_error_messages1!
     resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
   end

   def devise_error_messages2!
     resource.errors.full_messages.map { |msg| content_tag(:p, msg) }.join
   end
end