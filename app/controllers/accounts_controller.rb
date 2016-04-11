class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts
  def index
    @accounts = Account.includes(:entries).arrange(order: 'type, name')
  end

  # GET /accounts/1
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_to Account, notice: 'Account was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      redirect_to Account, notice: 'Account was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /accounts/1
  def destroy
    if @account.destroy
      redirect_to Account, notice: 'Account was successfully destroyed.'
    else
      redirect_to Account, flash: { error: "Account could not be destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
      params.require(:account).permit(:name, :type, :parent_id)
    end
end