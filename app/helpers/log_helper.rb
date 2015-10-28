module LogHelper
  def logs( obj, options = {} )
    logs = []
    logs << obj.history_tracks.to_a
    logs << nested_relations(obj)
    # logs << ActivityLog.for_associated(obj).to_a
    logs.flatten.compact.sort{ |a,b| b.created_at <=> a.created_at }
  end

  def nested_relations(obj)
    # Using whitelisted classes denfined in the parent models
    relations = Settings.trackable_relations.send(params[:controller])
    if relations.present?
      relations = relations.map{ |rels| obj.send(rels) }.flatten
      relations.map{ |rel| rel.history_tracks }.flatten
    end
  end
end
