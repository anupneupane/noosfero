require File.dirname(__FILE__) + '/../test_helper'
require 'search_controller'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < Test::Unit::TestCase
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'find enterprise' do
    ent = Enterprise.create!(:name => 'teste', :identifier => 'teste')
    get 'index', :query => 'teste'
    assert_response :success
    assert_template 'index'
    assert assigns('results')
    assert assigns('results').include?(ent)

  end

end
