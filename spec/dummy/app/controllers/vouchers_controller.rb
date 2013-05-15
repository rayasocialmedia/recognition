class VouchersController < ApplicationController
  # GET /vouchers
  # GET /vouchers.json
  def index
    @vouchers = Voucher.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @vouchers }
    end
  end

  # GET /vouchers/1
  # GET /vouchers/1.json
  def show
    @voucher = Voucher.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @voucher }
    end
  end

  # GET /vouchers/new
  # GET /vouchers/new.json
  def new
    @voucher = Voucher.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @voucher }
    end
  end

  # GET /vouchers/1/edit
  def edit
    @voucher = Voucher.find(params[:id])
  end

  # POST /vouchers
  # POST /vouchers.json
  def create
    @voucher = Voucher.new(params[:voucher])

    respond_to do |format|
      if @voucher.save
        format.html { redirect_to @voucher, notice: 'Voucher was successfully created.' }
        format.json { render json: @voucher, status: :created, location: @voucher }
      else
        format.html { render action: "new" }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /vouchers/1
  # PUT /vouchers/1.json
  def update
    @voucher = Voucher.find(params[:id])

    respond_to do |format|
      if @voucher.update_attributes(params[:voucher])
        format.html { redirect_to @voucher, notice: 'Voucher was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vouchers/1
  # DELETE /vouchers/1.json
  def destroy
    @voucher = Voucher.find(params[:id])
    @voucher.destroy

    respond_to do |format|
      format.html { redirect_to vouchers_url }
      format.json { head :no_content }
    end
  end
end
