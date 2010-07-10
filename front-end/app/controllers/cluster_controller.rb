class ClusterController < ApplicationController
  def manage
    per_page = 10
    @rest_instances = RestInstance.paginate :page => params[:r_page], :per_page => per_page
    @stream_instances = StreamInstance.paginate :page => params[:s_page], :per_page => per_page
    @analytical_instances = AnalyticalInstance.paginate :page => params[:a_page], :per_page => per_page
    respond_to do |format|
      format.html {render "/cluster/manage", :layout => 'main'}
      format.js {
        render :update do |page|
          page.replace_html "restInstance", :partial => "instances/instance_index", :locals => {:instances => @rest_instances, :instance_header => "Rest Instances", :elem_id => "restInstance", :page_param => "r_page"}
          page.replace_html "streamInstance", :partial => "/instances/instance_index", :locals => {:instances => @stream_instances, :instance_header => "Stream Instances", :elem_id => "streamInstance", :page_param => "s_page"}
          page.replace_html "analyticalInstance", :partial => "/instances/instance_index", :locals => {:instances => @analytical_instances, :instance_header => "Analytical Instances", :elem_id => "analyticalInstance", :page_param => "a_page"}
        end
      }
    end
  end
  
  def kill_instance
    @instance = params[:instance_type].classify.constantize.find(params[:id])
    if !@instance.nil?
      `ssh toast '#{@instance.hostname} 'kill #{@instance.pid}''`
      @instance.pid = 0
    end
  end
  
  def start_instance
    #http://www.linuxquestions.org/questions/linux-software-2/how-to-send-a-command-to-a-screen-session-625015/
  end
end