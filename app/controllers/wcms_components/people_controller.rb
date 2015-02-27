class WcmsComponents::PeopleController < ApplicationController

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    # For security reasons, this should only be available to employees.
    if current_user.admin? || current_user.has_role?(:employee)
      if params[:q].present?
        @people = permitted_people.custom_search(params[:q]).asc(:first_name, :last_name).limit(20)
      else
        # If no query string is present, return all faculty for pre-cached data.
        @people = permitted_people.where(affiliations: 'faculty').custom_search(params[:q]).asc(:first_name, :last_name)
      end

      render json: @people.map{|p| {id: p.id.to_s, name: p.name, email: p.biola_email, affiliations: p.affiliations.to_a.join(', '), image: p.profile_photo_url} }.to_json
    else
      user_not_authorized
    end
  end


  private

  def permitted_people
    # Return all people who are either employees or not private.
    Person.where({'$or' => [{affiliations: ['employee'] }, {privacy: { '$ne' => true }}] })
  end

end
