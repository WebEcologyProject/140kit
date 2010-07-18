class ClusterController < ApplicationController
  
  before_filter :admin_required
  
  def manage
    @page_title = "Cluster Management"
    per_page = 10
    @rest_instances = RestInstance.paginate :page => params[:r_page], :per_page => per_page
    @stream_instances = StreamInstance.paginate :page => params[:s_page], :per_page => per_page
    @analytical_instances = AnalyticalInstance.paginate :page => params[:a_page], :per_page => per_page
    respond_to do |format|
      format.html {render "/cluster/manage", :layout => 'main'}
      format.js {
        render :update do |page|
          page.replace_html "restInstance", :partial => "/instances/instance_index", :locals => {:instances => @rest_instances, :instance_header => "Rest Instances", :elem_id => "restInstance", :page_param => "r_page"}
          page.replace_html "streamInstance", :partial => "/instances/instance_index", :locals => {:instances => @stream_instances, :instance_header => "Stream Instances", :elem_id => "streamInstance", :page_param => "s_page"}
          page.replace_html "analyticalInstance", :partial => "/instances/instance_index", :locals => {:instances => @analytical_instances, :instance_header => "Analytical Instances", :elem_id => "analyticalInstance", :page_param => "a_page"}
        end
      }
    end
  end
  
  def instance_show
    per_page = 10
    @instance = params[:instance_type].classify.constantize.find(:first, :conditions => {:instance_id => params[:instance_id]})
    @finished_jobs = @instance.metadatas.select{|m| m.finished }.paginate :page => params[:f_page], :per_page => per_page
    @unfinished_jobs = @instance.metadatas.select{|m| !m.finished }.paginate :page => params[:uf_page], :per_page => per_page
    @partial_path = @instance.metadatas.first.class.to_s.underscore
    @page_title = "Instance Management : #{@instance.hostname}/#{@instance.instance_name}"
    respond_to do |format|  
      format.html {render "/instances/show", :layout => 'main'}
      format.js {
        render :update do |page|
          page.replace_html "unfinished", :partial => "/instances/#{@partial_path}/index", :locals => {:jobs => @unfinished_jobs, :elem_id => "unfinished", :page_param => "uf_page"}
          page.replace_html "finished", :partial => "/instances/#{@partial_path}/index", :locals => {:jobs => @finished_jobs, :elem_id => "finished", :page_param => "f_page"}        
        end
      }
    end
  end
  
  def machine_show
    per_page = 10
    @analytical_instances = AnalyticalInstance.paginate :all, :page => params[:analytical_instances_page], :per_page => per_page, :conditions => {:slug => params[:slug]}
    @stream_instances = StreamInstance.paginate :all, :page => params[:stream_instances_page], :per_page => per_page, :conditions => {:slug => params[:slug]}
    @rest_instances = RestInstance.paginate :all, :page => params[:rest_instances_page], :per_page => per_page, :conditions => {:slug => params[:slug]}
    if !@analytical_instances.empty?
      @name = @analytical_instances.first.hostname
      @slug = @analytical_instances.first.slug
    elsif !@stream_instances.empty?
      @name = @stream_instances.first.hostname
      @slug = @stream_instances.first.slug
    elsif
      @name = @stream_instances.first.hostname
      @slug = @stream_instances.first.slug
    else
      @name = "Not Found"
      @slug = params[:slug]
    end
    @job_set = {"analytical_instances" => @analytical_instances, "stream_instances" => @stream_instances, "rest_instances" => @rest_instances}
    @page_title = "Machine Management : #{@name}"
    respond_to do |format|  
      format.html {render "/cluster/machine_show", :layout => 'main'}
      format.js {
        render :update do |page|
          @job_set.each_pair do |job_type, jobs|
          page.replace_html job_type, :partial => "/instances/index", :locals => {:jobs => jobs, :elem_id => job_type, :page_param => job_type+"_page"}
          end
        end
      }
    end
  end
  
  def kill_instance
    @instance = params[:instance_type].classify.constantize.find(params[:id])
    @instance.killed = true
    @instance.save
    redirect_to(request.referrer)
  end
  
  def resurrect_instance
    @instance = params[:instance_type].classify.constantize.find(params[:id])
    @instance.killed = false
    @instance.save
    redirect_to(request.referrer)
  end
  
  def job_form
    @job = params[:instance_type].classify.constantize.find(params[:id])
    @instances = @job.instance.class.all
    @submit = params[:submit_type]
    if request.xhr?
      render :update do |page|
        page.replace_html 'main', :partial => "/instances/jobs/form", :locals => {
            :job => @job, 
            :submit => @submit
        }
      end
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => inst_var }
      end
    end
  end
  
  def restart_job
    @job = params[:instance_type].classify.constantize.find(params[:id])
    @job.finished = false
    @job.instance_id = params[:job][:instance_id]
    @job.save
    flash[:notice] = "#{@job.function} for #{@job.collection.name} was restarted on #{@job.instance.hostname}/#{@job.instance.instance_name}"
    redirect_to(request.referrer)
  end
  
  def reassign_job
    @job = params[:instance_type].classify.constantize.find(params[:id])
    @job.finished = false
    @job.instance_id = params[:job][:instance_id]
    @job.save
    flash[:notice] = "#{@job.function} for #{@job.collection.name} was restarted on #{@job.instance.hostname}/#{@job.instance.instance_name}"
    redirect_to(request.referrer)
  end
  
  def machine_form
    @slug = params[:slug]
    @instances = params[:instance_type].classify.constantize.all-AnalyticalInstance.find_all_by_slug(params[:slug])
    @all_instances = params[:instance_type].classify.constantize.all
    @submit = params[:submit_type]
    @instance_type = params[:instance_type]
    if request.xhr?
      render :update do |page|
        page.replace_html 'main', :partial => "/instances/machines/form", :locals => {
            :slug => @slug, 
            :instances => @instances,
            :submit => @submit,
            :instance_type => params[:instance_type]
        }
      end
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => inst_var }
      end
    end
  end
  
  def restart_machine_jobs
    @new_machine_instances = params[:instance_type].classify.constantize.find(:all, :conditions => {:slug => params[:machine][:slug]})
    jobs = params[:instance_type].classify.constantize.find(:all, :conditions => {:slug => params[:slug]}).collect{|i| i.metadatas}.flatten
    moved_jobs = []
    counter = 0
    while !jobs.empty?
      counter = 0 if counter == @new_machine_instances.length
      job = jobs.first
      job.instance_id = @new_machine_instances[counter].instance_id
      job.finished = false
      job.save
      moved_jobs << job
      jobs = jobs-[job]
      counter+=1
    end
    flash[:notice] = "#{moved_jobs.length} jobs restarted on #{@new_machine_instances.first.hostname}"
    redirect_to(request.referrer)
  end
  
  def reassign_machine_jobs
    @new_machine_instances = params[:instance_type].classify.constantize.find(:all, :conditions => {:slug => params[:machine][:slug]})
    jobs = params[:instance_type].classify.constantize.find(:all, :conditions => {:slug => params[:slug]}).collect{|i| i.metadatas}.flatten
    moved_jobs = []
    counter = 0
    while !jobs.empty?
      counter = 0 if counter == @new_machine_instances.length
      job = jobs.first
      job.instance_id = @new_machine_instances[counter].instance_id
      job.save
      moved_jobs << job
      jobs = jobs-[job]
      counter+=1
    end
    flash[:notice] = "#{moved_jobs.length} jobs moved to <a href=\"/machines/#{@new_machine_instances.first.slug}\">#{@new_machine_instances.first.hostname}</a>"
    redirect_to(machine_show_path(@new_machine_instances.first.slug))
  end
end