class MeetupGroup < ActiveRecord::Base

  validates_presence_of   :mu_id, :mu_name, :mu_link
  validates_uniqueness_of :mu_id

  has_many :group_users, class_name: 'UserGroup', foreign_key: :group_mu_id, primary_key: :mu_id
  has_many :users, through: :group_users, source: :user


  # class methods

  def self.build_with(meetup_group_hash)
    group = new()
    group.refresh_with(meetup_group_hash)

    group
  end

  def self.import_with(meetup_group_hash)
    h = meetup_group_hash
    if exists?(["mu_id=?", h["id"]])
      group = find_by_mu_id(h["id"])
      group.refresh_with(h)
    else
      group = build_with(h)
    end
    group.save!
    group
  end


  # instance methods

  def add(user)
    return user if user.member_of?(self)

    assoc = UserGroup.new
    assoc.user = user
    assoc.group = self
    assoc.save!

    user
  end

  def refresh_with(meetup_group_hash)
    h = meetup_group_hash

    self.mu_id = h["id"]
    self.mu_name = h["name"]
    self.mu_link = h["link"]
    self.city = h["city"]
    self.state = h["state"]
    self.country = h["country"]
    self.description = h["description"]
    self.urlname = h["urlname"]
    self.visibility = h["visibility"]
    self.who = h["who"]

    organizer = h["organizer"]
    self.mu_organizer_id = organizer["member_id"]
    self.mu_organizer_name = organizer["name"]

    photo = h["group_photo"]
    self.mu_photo_link = photo["photo_link"]
    self.mu_highres_link = photo["highres_link"]
    self.mu_thumb_link = photo["thumb_link"]
    self.mu_photo_id = photo["photo_id"]
  end

end
