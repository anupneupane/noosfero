require "#{File.dirname(__FILE__)}/../test_helper"

class ManageDocumentsTest < ActionController::IntegrationTest

  all_fixtures

  def test_creation_of_a_new_article
    create_user('myuser')

    login('myuser', 'myuser')

    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser'  }
    get '/myprofile/myuser'
    
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser/cms' }
    get '/myprofile/myuser/cms/new'

    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser/cms/new?type=TinyMceArticle' }
    get '/myprofile/myuser/cms/new?type=TinyMceArticle'

    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/myuser/cms/new', :method => /post/i }

    assert_difference Article, :count do
      post '/myprofile/myuser/cms/new', :type => 'TinyMceArticle', :article => { :name => 'my article', :body => 'this is the body of ther article'}
    end

    assert_response :redirect
    follow_redirect!
    a = Article.find_by_path('my-article')
    assert_equal "/myprofile/myuser/cms/view/#{a.id}", path
  end

  def test_update_of_an_existing_article
    profile = create_user('myuser').person
    article = profile.articles.build(:name => 'my-article')
    article.save!

    login('myuser', 'myuser')

    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser'  }
    get '/myprofile/myuser'
    assert_response :success
    
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser/cms' }
    get '/myprofile/myuser/cms'
    assert_response :success

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/myuser/cms/view/#{article.id}"}
    get "/myprofile/myuser/cms/view/#{article.id}"
    assert_response :success

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/myuser/cms/edit/#{article.id}"}
    get "/myprofile/myuser/cms/edit/#{article.id}"
    assert_response :success

    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/myuser/cms/edit/#{article.id}", :method => /post/i }

    assert_no_difference Article, :count do
      post "/myprofile/myuser/cms/edit/#{article.id}", :article => { :name => 'my article', :body => 'this is the body of the article'}
    end

    article.reload
    assert_equal 'this is the body of the article', article.body

    assert_response :redirect
    follow_redirect!
    a = Article.find_by_path('my-article')
    assert_equal "/myprofile/myuser/cms/view/#{a.id}", path
  end

  def test_removing_an_article
    profile = create_user('myuser').person
    article = profile.articles.build(:name => 'my-article')
    article.save!

    login('myuser', 'myuser')

    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser'  }
    get '/myprofile/myuser'
    assert_response :success
    
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser/cms' }
    get '/myprofile/myuser/cms'
    assert_response :success

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/myuser/cms/view/#{article.id}"}
    get "/myprofile/myuser/cms/view/#{article.id}"
    assert_response :success

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/myuser/cms/destroy/#{article.id}", :onclick => /confirm/ }
    post "/myprofile/myuser/cms/destroy/#{article.id}"

    assert_response :redirect
    follow_redirect!
    assert_equal "/myprofile/myuser/cms", path
  
    # the article was actually deleted
    assert_raise ActiveRecord::RecordNotFound do
      Article.find(article.id)
    end
  end

end
