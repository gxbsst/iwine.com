ActiveAdmin.register Wine do

  controller do
    def update
      @wine = Wine.find(params[:id])
      if @wine.update_attributes(params[:wine])
        redirect_to admin_wine_path(@wine)
      else
        render :action => :edit
      end
    end
  end
  form :partial => "form"
end
