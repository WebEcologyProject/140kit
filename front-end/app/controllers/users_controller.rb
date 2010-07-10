class UsersController < ApplicationController
  layout 'main'

  def show
    params[:page] = 1 if params[:page].class == NilClass || params[:page].nil || params[:page].empty?
    @user = User.find(:first, :conditions => {:screen_name => params[:screen_name]})
    @tweets = Tweet.paginate :page => params[:page], :conditions => {:screen_name => params[:screen_name]}, :per_page => 10
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def collection_paginate
    @collection = Collection.find(params[:id])
    rm_ids = @collection.rest_metadatas.collect{|rm| rm.id}
    sm_ids = @collection.stream_metadatas.collect{|sm| sm.id}
    rm_conditional = rm_ids.empty? ? "" : "(metadata_type = 'rest_metadata' and ( metadata_id = '#{rm_ids.join("\' or metadata_id = \'")}'))"
    sm_conditional = sm_ids.empty? ? "" : "(metadata_type = 'stream_metadata' and ( metadata_id = '#{sm_ids.join("\' or metadata_id = \'")}'))"
    if rm_ids.empty?
      conditional = sm_conditional
    elsif sm_ids.empty?
      conditional = rm_conditional
    elsif !rm_ids.empty? && !sm_ids.empty?
      conditional = rm_ids+" or "+sm_ids
    end
    index(conditional, 10, 'dataDisplay')
  end

  def collection_paginate_dataset
    index({:metadata_type => params[:metadata_type], :metadata_id => params[:id]}, 10, 'dataDisplay')
  end
end
