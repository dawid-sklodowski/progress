require 'spec_helper'
require 'progress2'

class BlockEvaluated < StandardError;end

describe AppScaffold do
  describe 'get' do
    it 'creates route for GET request' do
      class AppTest < AppScaffold
        get '/test' do
          raise BlockEvaluated
        end
      end
      routes = AppTest.instance_variable_get(:'@routes')
      routes['GET']['/test'].should be_kind_of(Proc)
      expect{routes['GET']['/test'].call}.to raise_error(BlockEvaluated)
    end
  end

  describe 'post' do
    it 'creates route for GET request' do
      class AppTest < AppScaffold
        post '/test' do
          raise BlockEvaluated
        end
      end
      routes = AppTest.instance_variable_get(:'@routes')
      routes['POST']['/test'].should be_kind_of(Proc)
      expect{routes['POST']['/test'].call}.to raise_error(BlockEvaluated)
    end
  end
end
