module Store
  module Nodes
    def to_nodes_pk(field, val)
      @models[:node] ||= {}
      @models[:node][:resource_pk] = val
    end

    def to_nodes_page_id(field, val)
      @models[:node] ||= {}
      @models[:node][:page_id] = val
    end

    def to_nodes_scientific(field, val)
      @models[:node] ||= {}
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:verbatim] = val
    end

    def to_nodes_parent_fk(field, val)
      @models[:node] ||= {}
      @models[:node][:parent_resource_pk] = val
    end

    def to_nodes_ancestor(field, val)
      @models[:ancestors] ||= {}
      @models[:ancestors][field.submapping] = val
    end

    def to_nodes_rank(field, val)
      @models[:node] ||= {}
      @models[:node][:rank_verbatim] = val
    end

    def to_nodes_further_information_url(field, val)
      @models[:node] ||= {}
      @models[:node][:further_information_url] = val
    end

    def to_taxonomic_status(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:taxonomic_status_verbatim] = val
    end

    def to_nodes_accepted_name_fk(field, val)
      # TODO: What we really want to do here is, if there is a value here, move all of the fields from the node to the
      # scientific name, but that's hairy and I don't want to do it right now. Soon.
      @models[:node] ||= {}
      debugger unless val.blank? || val == @models[:node][:resource_pk]
      1
    end

    def to_nodes_remarks(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:remarks] = val
    end

    def to_nodes_publication(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:publication] = val
    end

    def to_nodes_source_reference(field, val)
      @models[:scientific_name] ||= {}
      @models[:scientific_name][:source_reference] = val
    end
  end
end
