class ResearchersController < ApplicationController

  def index
    @stats = {}
    @stats["online"] = "Of course. That's how the internet works."
    @stats["requested_at"] = Time.now
    @stats["total_tweets"] = ActiveRecord::Base.connection.execute("select count(*) from tweets").fetch_row.first
    @stats["total_users"] = ActiveRecord::Base.connection.execute("select count(*) from users").fetch_row.first
    @stats["number_collections"] = ActiveRecord::Base.connection.execute("select count(*) from collections").fetch_row.first
    @stats["researchers_active"] = ActiveRecord::Base.connection.execute("select count(*) from researchers").fetch_row.first
    @stats["scrape_count"] = ActiveRecord::Base.connection.execute("select count(*) from scrapes").fetch_row.first
    @stats["datasets_count"] = ActiveRecord::Base.connection.execute("select count(*) from collections where single_dataset = 1").fetch_row.first
    @stats["analysis_jobs_completed"] = ActiveRecord::Base.connection.execute("select count(*) from analysis_metadatas").fetch_row.first
    @stats["total_graphs"] = ActiveRecord::Base.connection.execute("select count(*) from graphs").fetch_row.first
    @stats["total_graph_points"] = ActiveRecord::Base.connection.execute("select count(*) from graph_points").fetch_row.first
    @stats["total_edges"] = ActiveRecord::Base.connection.execute("select count(*) from edges").fetch_row.first
    respond_to do |format|
      format.xml  { render :xml => @stats.to_xml }
      format.json  { render :json => @stats.to_json }
    end
  end

  def show
    @researcher = Researcher.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => @researcher }
      format.json  { render :json => @researcher }
    end
  end

  def api_query
    b = 0
    @researchers = interpret_request(params)
    respond_to do |format|
      format.xml  { render :xml => @researchers.to_xml }
      format.json  { render :json => @researchers.to_json }
    end    
  end

  def relational_query
    b = 0
    @researchers = super
    respond_to do |format|
      format.xml  { render :xml => @researchers.to_xml }
      format.json  { render :json => @researchers.to_json }
    end    
  end

end
