class WcmsComponents::PeopleController < ApplicationController

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    if can_search_people?
      if params[:q].present?
        @people = permitted_people.custom_search(params[:q]).asc(:first_name, :last_name).limit(10)
      else
        # If no query string is present, return all faculty for pre-cached data.
        @people = []
      end

      render json: @people.map{|p| {id: p.id.to_s, name: p.name, email: p.biola_email, affiliations: p.affiliations.to_a.join(', '), image: p.profile_photo_url} }.to_json
    else
      user_not_authorized
    end
  end


  private

  def permitted_people
    # Return all people who are either employees, faculty, trustees, contractors, or not private.
    Person.where({'$or' => [{affiliations: 'employee'}, {affiliations: 'faculty'}, {affiliations: 'trustee'}, {affiliations: 'contractor'}, {privacy: { '$ne' => true }}] })
  end

  def can_search_people?
    # For security reasons, this should only be available to employees and student workers
    current_user.admin? || current_user.has_role?(:employee) || current_user.has_role?(:student_worker)
  end

end
