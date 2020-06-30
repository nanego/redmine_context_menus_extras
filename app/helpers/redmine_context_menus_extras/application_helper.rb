module RedmineContextMenusExtras
  module ApplicationHelper
    def bulk_new_error_messages(items, id_method = :id)
      messages = {}
      items.each do |item|
        item.errors.full_messages.each do |message|
          messages[message] ||= []
          messages[message] << item
        end
      end
      messages.map { |message, items|
        "#{message}: " + items.map {|i| "##{i.public_send(id_method)}"}.join(', ')
      }
    end
  end
end
