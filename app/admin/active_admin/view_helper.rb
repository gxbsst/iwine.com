#encoding: utf-8
module ActiveAdmin::ViewHelpers
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("update_#{association.to_s}", :item => builder)
    end
    link_to_function(name, ("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

  def return_url(imageable_type, imageable_id)
      "admin/photos/edit_images?imageable_type=#{imageable_type}&imageable_id=#{imageable_id}"
  end

  def photo_type(value)
    type = [ "正常", "标志", "封面"]
    type[value.to_i]
  end
end
