class USQL < ActiveRecord::Base
  
  def self.resolve_query(model, query, pre_conditions)
    case model
    when "Tweet"
      attributes = ["text", "screen_name", "in_reply_to_screen_name"]
    	conditions = USQL.advanced_conditioning(pre_conditions, attributes, query)
    when "User"
      attributes = ["name", "screen_name", "description"]
    	conditions = USQL.advanced_conditioning(pre_conditions, attributes, query)
    when "Researcher"
      attributes = ["user_name", "info"]
    	conditions = USQL.advanced_conditioning(pre_conditions, attributes, query)
    when "Graph"
      attributes = ["title", "style"]
    	conditions = USQL.advanced_conditioning(pre_conditions, attributes, query)
    when "Collection"
      attributes = ["name", "folder_name"]
    	conditions = USQL.advanced_conditioning(pre_conditions, attributes, query)
    end
  	return conditions
  end
  
  def self.advanced_conditioning(pre_conditions, attributes, query)
    condition_string = pre_conditions.empty? ? " ("+attributes.join(" like ? or ")+" like ?)" : pre_conditions+" and ("+attributes.join(" like ? or ")+" like ?)"
  	conditions = [condition_string]
    attributes.length.times do |append|
      conditions << "%#{query}%"
    end
  	return conditions    
  end
  
  def self.resolve_pre_existing_conditions(conditions)
    resolved_conditions = {}
    conditional_pairs = conditions.to_s.split("|")
    conditional_pairs.each do |pair|
      key = pair.split(":")[0].split(",")
      value = pair.split(":")[1].split(",")
      resolved_conditions[key] = value
    end
    return USQL.where(resolved_conditions)
  end
  
  def self.where(parameters)
    query = ""
    if !parameters.empty?
      parameters.each_pair {|k,v|
        if k.class == Array && k.length > 1
          if v.class == Array && v.length > 1
            k.each do |key|
              query += " and ("
              v.each do |val|
                query += " #{key} = #{val} or "
              end
              query.chop!.chop!.chop!.chop!
              query += ")"
            end
          else
            query = " and ("
            k.each do |key|
              query += " #{key} = #{v} or "
            end
            query.chop!.chop!.chop!.chop!
            query += ")"
          end
        else
          if v.class == Array && v.length > 1
            query += " and ("
            v.each do |val|
              query += " #{k} = #{val} or "
            end
            query.chop!.chop!.chop!.chop!
            query += ")"
          else
            query += " and #{k} = #{v} "
          end
        end
      }
    end
    query_clean = query.scan(/^ \w* (.*)/)
    query = " "+query_clean[0][0]+" "
    return query
  end
end