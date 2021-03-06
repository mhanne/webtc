class VerificationRulesController < ApplicationController

  before_filter :authenticate_user!

  def index
    @verification_rules = current_user.verification_rules.order(:amount)
    @page_title = t('verification_rules.index.title')
  end

  def new
    @verification_rule = VerificationRule.new
    @page_title = t('verification_rules.new.title')
  end

  def create
    @verification_rule = VerificationRule.new(params[:verification_rule])
    @verification_rule.user = current_user
    @verification_rule.amount = parse_amount(params[:verification_rule][:amount])
    if @verification_rule.save
      flash[:notice] = t('verification_rules.create.notice')
      redirect_to account_settings_path
    else
      @page_title = t('verification_rules.new.title')
      render :action => :new
    end
  end

  def destroy
    @verification_rule = VerificationRule.find(params[:id])
    if current_user == @verification_rule.user && @verification_rule.delete
      flash[:notice] = t('verification_rules.delete.notice')
      redirect_to account_settings_path
    end
  end

end
