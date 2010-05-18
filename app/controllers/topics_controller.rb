# -*- coding: utf-8 -*-
class TopicsController < ApplicationController
  before_filter :require_user, :except => [:index, :show]

  before_filter :require_admin, :only => [:new, :create, :edit, :destroy,
                                          :update, :moderate]
  layout 'discussions'

  def index
    if !params[:type]
      @topics = Topic.paginate(:page=> params[:page], :per_page => 20,
                               :order => 'commented_at DESC')
    elsif %w[contest problem lesson topic].include? params[:type]
      @topics = params[:type].capitalize.constantize.commented.
        paginate(:page=> params[:page], :per_page => 20, 
                 :order => 'commented_at DESC')
    end
  end

  def show
    if !params[:type]
      @topic = Topic.
        find(params[:id])
    elsif %w[contest problem lesson topic].include? params[:type]
      @topic = params[:type].capitalize.constantize.find(params[:id])
    end
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:notice] = 'Topic was successfully created.'
      redirect_to @topic
    else
      render :action => 'new'
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = 'Topic was successfully updated.'
      redirect_to @topic
    else
      render :action => 'edit'
    end
  end

  def destroy
    Topic.find(params[:id]).destroy
    redirect_to :action => :index
  end
end
