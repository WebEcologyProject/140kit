class NetworksController < ApplicationController
  layout "main"
  
  require 'net/http'
  require 'open-uri'
  
  def index
    @collections = Collection.all
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collections }
    end
  end
  
  def show
    @collection = Collection.find(params[:collection_id])
    # @api_url = "http://#{API_URL}/networks/#{params[:collection_id]}/#{params[:style]}.graphml"
    api_suffix = "/networks/#{params[:collection_id]}/#{params[:style]}.json"
    logger.debug(params.inspect)
    if params[:logic].nil?
      params[:logic] = "conn_comp:0"
    elsif !params[:logic].include?("conn_comp:")
      params[:logic] += "|conn_comp:0"
    end
    api_suffix += "?logic="
    api_suffix += "conn_comp:0|" if !params[:logic].include?("conn_comp:")
    api_suffix += "#{params[:logic]}"
    for param in params[:logic].split('|')
      kv = param.split(':')
      params[kv[0]] = kv[1]
    end
    logger.debug(params.inspect)
    internal_call = "http://#{API_URL}#{api_suffix}"
    @api_url = "http://api.140kit.com#{api_suffix}"
    logger.debug("\napi_url: #{URI.parse(URI.encode(internal_call))}")
    @json = open(URI.parse(URI.encode(internal_call))).read
  end
  
  def flare
    @collection = Collection.find(params[:collection_id])
    @api_url = "http://#{API_URL}/networks/#{params[:collection_id]}/#{params[:style]}.graphml"
    if !params[:logic].nil?
      @api_url += "?logic=#{params[:logic]}"
      for param in params[:logic].split('|')
        kv = param.split(':')
        params[kv[0]] = kv[1]
      end
    end
    @api_url = URI.parse(URI.encode(@api_url)).to_s
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collection }
    end
  end
  
  def sh0w
    @collection = Collection.find(params[:collection_id])
    @api_url = "http://#{API_URL}/networks/#{params[:collection_id]}/#{params[:style]}.graphml"
    if !params[:logic].nil?
      @api_url += "?logic=#{params[:logic]}"
      for param in params[:logic].split('|')
        kv = param.split(':')
        params[kv[0]] = kv[1]
      end
    end
    @api_url = URI.parse(URI.encode(@api_url)).to_s
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collection }
    end
  end
  
  def submit
    collection_id = params[:logic_params]["f_collection_id"].blank? ? params[:logic_params]["collection_id"] : params[:logic_params]["f_collection_id"]
    params[:logic_params].delete("f_collection_id")
    params[:logic_params].delete("collection_id")
    style = params[:logic_params]["f_style"].blank? ? params[:logic_params]["style"] : params[:logic_params]["f_style"]
    params[:logic_params].delete("f_style")
    params[:logic_params].delete("style")
    logic = ""
    prep_logic(params[:logic_params]).each_pair do |key, value|
      logic += "#{key}:#{value}%7C" if !value.empty?
    end
    logic.chop!.chop!.chop! if !logic.empty?
    respond_to do |format|
      format.html { redirect_to "/networks/#{collection_id}/#{style}/#{logic}" }
    end
  end
  
  def submit_rgraph
    collection_id = params[:logic_params]["f_collection_id"].blank? ? params[:logic_params]["collection_id"] : params[:logic_params]["f_collection_id"]
    params[:logic_params].delete("f_collection_id")
    params[:logic_params].delete("collection_id")
    style = params[:logic_params]["f_style"].blank? ? params[:logic_params]["style"] : params[:logic_params]["f_style"]
    params[:logic_params].delete("f_style")
    params[:logic_params].delete("style")
    logic = ""
    prep_logic(params[:logic_params]).each_pair do |key, value|
      logic += "#{key}:#{value}%7C" if !value.empty?
    end
    logic.chop!.chop!.chop! if !logic.empty?
    respond_to do |format|
      format.html { redirect_to "/networks/#{collection_id}/#{style}/#{logic}" }
    end
  end
  
  private
  
  def find_connections(component, node_index, start_node)
    component += [start_node]
    for node in node_index[start_node]
      component += find_connections(component, node_index, node) if !(node_index[node] - component).empty?
    end
    return component.uniq
  end
  
  def prep_logic(params)
    index = { "limit" => { :type => "integer", :api_default => nil },
              "conn_comp" => { :type => "integer", :api_default => 0 },
              "verbose" => { :type => "boolean", :api_default => false }
            }
    params.each_pair do |key, value|
      case index[key][:type]
      when "boolean"
        value.to_i.to_bool == index[key][:api_default] ? params.delete(key) : params[key] = value.to_i.to_bool.to_s
      when "integer"
        value == index[key][:api_default].to_s ? params.delete(key) : params[key] = "#{value.to_i}"
      end
    end
    return params
  end


end
