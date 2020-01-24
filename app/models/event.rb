class Event < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :invitations, dependent: :destroy

  before_save :unique_slug

  def unique_slug
    self.slug = if self.slug.blank?
                  set_slug(Base64.strict_encode64(Time.now.to_i.to_s + self.title + "thexOwoA")[0...-2])
                else
                  set_slug(Base64.strict_encode64(Time.now.to_i.to_s + self.slug + "thexOwoA")[0...-2])
                end
  end

  def set_slug(val)
    event_by_slug = Event.find_by(slug: val)
    if event_by_slug.present? && event_by_slug != self
      random_number = rand(1000..9999)
      slug_split = val.split("-")
      if slug_split[-1].match? /^[0-9]+$/
        if slug_split.count > 1
          temp = slug_split[0..-2].join("-")
        else
          temp = slug_split[0]
        end
        set_slug(temp + "-" + random_number.to_s)
      else
        set_slug(val + "-" + random_number.to_s)
      end
    else
      val
    end
  end
end
