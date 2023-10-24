require_dependency "issue_relations_controller"

module RedmineContextMenusExtras::Controllers::IssueRelationsController
  def bulk_new
    raise ::Unauthorized unless allowed_to_bulk_action?

    @issues.sort!
    @issue = @issues.first
    @project = @issues.first.project
    @relation = IssueRelation.new
  end

  def bulk_create
    raise ::Unauthorized unless allowed_to_bulk_action?

    @issues.sort!

    unsaved_relations = []
    saved_relations = []

    @issues.each do |issue|
      next if issue.id == params[:relation][:issue_to_id].to_i

      relation = IssueRelation.new
      relation.issue_from = issue
      relation.safe_attributes = params[:relation]
      relation.init_journals(User.current)

      if relation.save
        saved_relations << relation
      else
        unsaved_relations << relation
      end
    end

    if unsaved_relations.empty?
      flash[:notice] = l(:notice_successful_create) unless saved_relations.empty?
      @redirect_to = request.headers["Referer"].presence || _project_issues_path(@project)
    else
      @saved_relations = saved_relations
      @unsaved_relations = unsaved_relations
      @issues = Issue.visible.where(:id => @unsaved_relations.map(&:issue_from_id)).to_a
      @issue = @issues.first
      bulk_new
    end
  end
end

class IssueRelationsController
  include RedmineContextMenusExtras::Controllers::IssueRelationsController

  before_action :find_issues, :only => [:bulk_new, :bulk_create]

  helper RedmineContextMenusExtras::ApplicationHelper

  private

  def allowed_to_bulk_action?
    return false unless @issues.all?(&:attributes_editable?)

    if !User.current.allowed_to?(:manage_issue_relations, @project) \
      && !User.current.allowed_to?(:manage_issue_relations, @projects)
      return false
    end

    true
  end
end
