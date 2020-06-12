class ContextMenusExtrasListener < Redmine::Hook::ViewListener
  render_on :view_issues_context_menu_end, :partial => "context_menus/issue_relations"
end