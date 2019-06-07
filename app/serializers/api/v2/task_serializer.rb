class Api::V2::TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :done, :deadline, :user_id, :short_description, :is_late, :created_at, :updated_at

  def short_description
    object.description[0..40]
  end

  def is_late
    Time.current > object.deadline if object.deadline.present?
  end

  belongs_to :user
end
