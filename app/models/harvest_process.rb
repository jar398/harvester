class HarvestProcess < ActiveRecord::Base
  belongs_to :resource, inverse_of: :harvest_processes

  def in_group_of_size(size)
    update_attribute(:current_group_size, size)
    update_attribute(:current_group_times, '')
    update_attribute(:current_group, 1)
  end

  def tick_group(time)
    if current_group_times.blank?
      update_attribute(:current_group_times, time)
    else
      update_attribute(:current_group_times, "#{current_group_times},#{time}")
    end
    update_attribute(:current_group, current_group + 1)
  end

  def update_group(position)
    update_attribute(:current_group, position)
  end

  def finished_group
    all_times = current_group_times.split(/,/)
    update_attribute(:current_group_size, 0)
    update_attribute(:current_group_times, '')
    update_attribute(:current_group, 0)
    all_times
  end

  def start(method_name)
    if method_breadcrumbs.blank?
      update_attribute(:method_breadcrumbs, method_name)
    else
      update_attribute(:method_breadcrumbs, "#{method_breadcrumbs},#{method_name}")
    end
  end

  def stop(method_name)
    return if method_breadcrumbs.blank?
    breadcrumbs = method_breadcrumbs.split(',')
    return unless breadcrumbs.include?(method_name.to_s)
    breadcrumbs.delete(method_name.to_s)
    update_attribute(:method_breadcrumbs, breadcrumbs.join(','))
  end
end
