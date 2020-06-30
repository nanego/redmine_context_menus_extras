require 'spec_helper'

describe IssueRelationsController, type: :controller do
  render_views

  fixtures :projects, :users, :roles, :members, :member_roles, :issues, :issue_statuses, :versions,
           :trackers, :projects_trackers, :issue_categories, :enabled_modules, :enumerations, :attachments,
           :workflows, :custom_fields, :custom_values, :custom_fields_projects, :custom_fields_trackers,
           :time_entries, :journals, :journal_details, :queries, :repositories, :changesets

  include Redmine::I18n

  before do
    @controller = described_class.new
    @request = ActionDispatch::TestRequest.create
    @response = ActionDispatch::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 2 #permissions are hard
  end

  let(:project) { Project.find(1) }
  let(:issues) { project.issues }

  describe "GET /issues/:issue_id/relations/bulk_new?ids[]=" do
    it "show form to bulk create issue relations for selected issues" do
      get :bulk_new, params: { issue_id: issues.first.id, ids: issues.map(&:id) }

      expect(response).to have_http_status(:success)
      expect(assigns(:project)).to eq(project)
      expect(assigns(:issues)).to eq(issues)
      expect(assigns(:issue)).to eq(issues.first)
      expect(assigns(:relation)).to be_a(IssueRelation)
      expect(response).to render_template(:bulk_new)
    end
  end

  describe "POST /issues/:issue_id/relations/bulk_create" do
    it "should not create relations unless issue_to_id specified" do
      post :bulk_create, params: {
        issue_id: issues.first.id,
        ids: issues.map(&:id),
        relation: {
          relation_type: "relates",
          issue_to_id: ""
        }
      }

      expect(response).to have_http_status(:success)
      expect(assigns(:saved_relations).count).to eq(0)
      expect(assigns(:unsaved_relations).count).to eq(issues.count)
      expect(assigns(:project)).to eq(project)
      expect(assigns(:issues)).to eq(issues)
      expect(assigns(:issue)).to eq(issues.first)
      expect(assigns(:relation)).to be_a(IssueRelation)
      expect(response).to render_template(:bulk_new)
    end

    it "should not create relations unless issue_to_id specified" do
      post :bulk_create, params: {
        issue_id: issues.first.id,
        ids: issues[0..1].map(&:id),
        relation: {
          relation_type: "relates",
          issue_to_id: issues.last
        }
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(project_issues_path(project_id: project))
    end
  end
end
