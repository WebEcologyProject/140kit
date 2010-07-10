class SiteData < Database
  
  `ls #{ROOT_FOLDER}cluster-code/site_data/`.split.each {|f| require "#{ROOT_FOLDER}cluster-code/site_data/#{f}"}
  
  @@models = `ls #{ROOT_FOLDER}cluster-code/site_data`.gsub(".rb", "").split("\n")
  @@classes = @@models.collect{|m| m.classify.constantize}+[Array, Hash]
  @@models << "metadatas"
  def initialize(attributes)
    attributes.each_pair do |k, v|
      self.send("#{k}=", v)
    end
  end
  
  def save
    accepted_classes = [String, Time, Integer, Float, Fixnum, TrueClass, FalseClass]
    obj_attrs = self.attributes
    safe_attrs = {}
    obj_attrs.each_pair do |k, v|
      if accepted_classes.include?(obj_attrs[k].class)
        safe_attrs[k] = v
      elsif v.class == Array
        if @@models.include?(obj_attrs[k].class.to_s.underscore.chop) && v.class != self.class
          v.each do |val|
            val.save
          end
        end
      else
        if @@models.include?(obj_attrs[k].class.to_s.underscore.chop) && v.class != self.class
          v.save
        end
      end
    end
    Database.save({self.class.to_s.underscore => [safe_attrs]})
    return self.class.find_all(SQLParser.prep_attributes(safe_attrs)).last
  end
  
  def self.save_all(parameters)
    parameters = [parameters].flatten
    if parameters.length == 1
      self.new(parameters.first.class == Hash ? parameters.first.reject{|k,v| @@classes.include?(v.class)} : parameters.first.attributes.reject{|k,v| @@classes.include?(v.class)}).save
    else
      parameters = parameters.collect{|p| p.attributes} if parameters.first.class != Hash
      parameters = {self.underscore.to_sym => parameters.collect{|p| p.reject{|k,v| @@classes.include?(v.class)}}}
      Database.save_all(parameters)
    end
  end
  
  def self.update_all(parameters)
    parameters = [parameters].flatten
    if parameters.length == 1
      self.new(parameters.first.class == Hash ? parameters.first.reject{|k,v| @@classes.include?(v.class)} : parameters.first.attributes.reject{|k,v| @@classes.include?(v.class)}).save
    else
      parameters = parameters.collect{|p| p.attributes} if parameters.first.class != Hash
      parameters = {self.underscore.to_sym => parameters.collect{|p| p.reject{|k,v| @@classes.include?(v.class)}}}
      Database.update_all(parameters)
    end
  end
  
  def self.find(parameters)
    parameters = self.sanitize_parameters(parameters)
    return SiteData.get(self, super)
  end

  def self.find_all(parameters)
    parameters = self.sanitize_parameters(parameters)
    return SiteData.get(self, super, true)
  end

  def self.all
    return super
  end

  def self.destroy_all(ids)
    parameters = {:class => self.underscore, :id => ids}
    destruction_results = Database.destroy_all(parameters)
  end
  
  def self.count(parameters=nil)
    if parameters.nil?
      return Database.result("select count(id) from #{self.underscore}").first.values.first 
    else
      conditional_statements = []
      parameters.each_pair do |k,v|
        if v.class == Array
          vv = v.collect{|v| SQLParser.prep_attribute(v)}
          conditional_statements <<  "#{k} = '#{vv.join("' or #{k} = '")}' "
        else
          conditional_statements <<  "#{k} = '#{SQLParser.prep_attribute(v)}' "
        end
      end
      condition = conditional_statements.join(" and ")
      return Database.result("select count(id) from #{self.underscore} where #{condition}").first.values.first 
    end
  end
  
  def destroy
    parameters = {:class => self.class.underscore, :id => self.id}
    destruction_results = Database.destroy(parameters)
  end
  
  def self.first
    objects = Database.find_first(self.name.underscore)
    return SiteData.get(self, objects)
  end

  def self.last
    objects = Database.find_last(self.name.underscore)
    return SiteData.get(self, objects)
  end

  def self.get(current_class, objects, *opts)
    return_array = opts[0] || false
    if objects.first.nil?
      return return_array ? [] : nil
    elsif objects.length == 1
      return return_array ? SiteData.load(current_class, objects) : SiteData.load(current_class, objects).first
    else
      return SiteData.load(current_class, objects)
    end    
  end

  def self.load(current_class, objects)
    return objects.collect{|object| current_class.new(object)}
  end
      
  def self.sanitize_parameters(parameters)
    new_parameters = {}
    new_parameters[:data] = parameters
    new_parameters[:limit] = parameters.class == Hash ? parameters.delete(:limit) : nil
    new_parameters[:order] = parameters.class == Hash ? parameters.delete(:order) : nil
    new_parameters[:class] = self.name.underscore
    return new_parameters
  end

  def attributes
    hash = {}
    self.instance_variables.collect{|var| var.gsub("@", "")}.each do |var|
      hash[var] = self.send(var)
    end
    return hash
  end
  
  def lock
    if $w.instance_id
      if self.instance_id
        self.instance_id = $w.instance_id
        self.save
        sleep(SLEEP_CONSTANT)
        object = AnalysisMetadata.find({:id => self.id, :instance_id => $w.instance_id})
        return !self.nil? ? self : nil
      end
    end
  end
  
  def locked?
    return $w.instance_id == self.instance_id
  end
end
