require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
  fixtures :profiles, :environments, :users

  def test_identifier_validation
    p = Profile.new
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'with space'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'áéíóú'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'rightformat2007'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'rightformat'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'right_format'
    p.valid?
    assert ! p.errors.invalid?(:identifier)
  end

  def test_has_domains
    p = Profile.new
    assert_kind_of Array, p.domains
  end

  def test_belongs_to_environment_and_has_default
    p = Profile.new
    assert_kind_of Environment, p.environment
  end

  def test_cannot_rename
    assert_valid p = Profile.create(:name => 'new_profile', :identifier => 'new_profile')
    assert_raise ArgumentError do
      p.identifier = 'other_profile'
    end
  end
 
  def test_should_provide_access_to_homepage
    profile = Profile.create!(:identifier => 'newprofile', :name => 'New Profile')
    page = profile.homepage
    assert_kind_of Article, page
    assert_equal profile.identifier, page.slug
  end

  def test_name_should_be_mandatory
    p = Profile.new
    p.valid?
    assert p.errors.invalid?(:name)
    p.name = 'a very unprobable name'
    p.valid?
    assert !p.errors.invalid?(:name)
  end

  def test_can_be_tagged
    p = Profile.create(:name => 'tagged_profile', :identifier => 'tagged')
    p.tags << Tag.create(:name => 'a_tag')
    assert Profile.find_tagged_with('a_tag').include?(p)
  end

  def test_can_have_affiliated_people
    pr = Profile.create(:name => 'composite_profile', :identifier => 'composite')
    pe = User.create(:login => 'aff', :email => 'aff@pr.coop', :password => 'blih', :password_confirmation => 'blih').person
    
    member_role = Role.new(:name => 'new_member_role')
    assert member_role.save
    assert pr.affiliate(pe, member_role)

    assert pe.memberships.include?(pr)
  end

  def test_search
    p = Profile.create(:name => 'wanted', :identifier => 'wanted')
    p.update_attribute(:tag_list, 'bla')

    assert Profile.search('wanted').include?(p)
    assert Profile.search('bla').include?(p)
    assert ! Profile.search('not_wanted').include?(p)
  end

  def test_should_remove_pages_when_removing_profile
    fail 'neet to be reimplemented'
  end

  def test_should_define_info
    assert_nil Profile.new.info
  end

  def test_should_avoid_reserved_identifiers
    assert_invalid_identifier 'admin'
    assert_invalid_identifier 'system'
    assert_invalid_identifier 'myprofile'
    assert_invalid_identifier 'profile'
    assert_invalid_identifier 'cms'
    assert_invalid_identifier 'community'
    assert_invalid_identifier 'test'
  end

  def test_should_provide_recent_documents
    profile = Profile.create!(:name => 'Testing Recent documents', :identifier => 'testing_recent_documents')
    doc1 = Article.new(:title => 'document 1', :body => 'la la la la la')
    doc1.parent = profile.homepage
    doc1.save!

    doc2 = Article.new(:title => 'document 2', :body => 'la la la la la')
    doc2.parent = profile.homepage
    doc2.save!

    docs = profile.recent_documents(2)
    assert_equal 2, docs.size
    assert docs.map(&:id).include?(doc1.id)
    assert docs.map(&:id).include?(doc2.id)
  end

  def test_should_provide_most_recent_documents
    profile = Profile.create!(:name => 'Testing Recent documents', :identifier => 'testing_recent_documents')
    doc1 = Article.new(:title => 'document 1', :body => 'la la la la la')
    doc1.parent = profile.homepage
    doc1.save!

    docs = profile.recent_documents(1)
    assert_equal 1, docs.size
    assert_equal doc1.id, docs.first.id
  end

  should 'provide a contact_email method which returns a ... contact email address' do
    p = Profile.create!(:name => 'Profile for testing ', :identifier => 'profilefortesting')
    assert_nil p.contact_email
    p.user = User.new(:email => 'testprofile@example.com')
    assert_equal 'testprofile@example.com', p.contact_email
  end

  should 'affiliate and provide a list of the affiliated users' do
    profile = Profile.create!(:name => 'Profile for testing ', :identifier => 'profilefortesting')
    person = create_user('test_user').person
    role = Role.create!(:name => 'just_another_test_role')
    assert profile.affiliate(person, role)
    assert profile.members.map(&:id).include?(person.id)
  end

  should 'authorize users that have permission on the environment' do
    env = Environment.create!(:name => 'test_env')
    profile = Profile.create!(:name => 'Profile for testing ', :identifier => 'profilefortesting', :environment => env)
    person = create_user('test_user').person
    role = Role.create!(:name => 'just_another_test_role', :permissions => ['edit_profile'])
    assert env.affiliate(person, role)
    assert person.has_permission?('edit_profile', profile)
  end

  private

  def assert_invalid_identifier(id)
    profile = Profile.new(:identifier => id)
    assert !profile.valid?
    assert profile.errors.invalid?(:identifier)
  end
end
