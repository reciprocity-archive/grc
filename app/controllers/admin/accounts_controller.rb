class Admin::AccountsController < ApplicationController
  layout "admin"

  # List accounts
  def index
    @accounts = Account.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @accounts }
    end
  end

  # Show one account
  def show
    @account = Account.get(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @account }
    end
  end

  # New account form
  def new
    @account = Account.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @account }
    end
  end

  # Edit account form
  def edit
    @account = Account.get(params[:id])
  end

  # Create an account
  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to(edit_account_path(@account), :notice => 'Account was successfully created.') }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Update an account
  def update
    @account = Account.get(params[:id])

    respond_to do |format|
      if @account.update(params[:account])
        if params[:account][:password]
          @account.crypted_password = nil
          @account.save
        end

        format.html { redirect_to(edit_account_path(@account), :notice => 'Account was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Delete an account
  def destroy
    @account = Account.get(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
end
