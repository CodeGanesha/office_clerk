# encoding : utf-8

class ProductsController < AdminController

  before_action :load_product, :only => [:show, :edit, :update, :destroy ]

  # Uncomment for check abilities with CanCan
  #authorize_resource

  def index
    param = params[:q] || {}
    param.merge!(:product_id_null => 1)    unless( params[:basket])
    @q = Product.search( param )
    @product_scope = @q.result(:distinct => true)
    @products = @product_scope.includes(:products , :supplier , :category).paginate( :page => params[:page], :per_page => 20 ).to_a
  end

  def show
    gon.product_id = @product.id
  end

  def new
    if params[:parent_id]
      parent = Product.find params[:parent_id]
      @product = parent.new_product_item
    else
      @product = Product.new :tax => OfficeClerk.config("defaults.tax")
    end
    render :edit
  end

  def edit
  end

  def create
    @product = Product.create(params_for_model)
    if @product.save
      flash.notice = t(:create_success, :model => "product")
      show = @product.product_item? ? @product.product : @product
      redirect_to product_path(show)
    else
      flash.alert = t(:fix_errors, :model => "product")
      render :action => :edit
    end
  end

  def update
    respond_to do |format|
      if @product.update_attributes(params_for_model)
        format.html { redirect_to(@product, :notice => t(:update_success, :model => "product")) }
        format.json { respond_with_bip(@product) }
      else
        format.html { render :action => :edit }
        format.json { respond_with_bip(@product) }
      end
    end
  end

  def destroy
    @product.delete
    if @product.save
      redirect_to products_url , :notice => t("deleted") + ": " + @product.full_name
    else
      redirect_to product_url(@product) , :notice => "#{t(:error)} : #{t(:product_has_inventory)}"
    end
  end

  def load_product
    @product = Product.find(params[:id])
  end

  def params_for_model
    params.require(:product).permit(:price,:cost,:weight,:name,:description, :online, :summary,:stock_level,
      :link,:ean,:tax,:properties,:scode,:product_id,:category_id,:supplier_id, :main_picture,:extra_picture
)
  end
end
