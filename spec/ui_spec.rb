require 'spec_helper'
require_relative '../app/run'

describe 'the UI' do
  def app
    Sinatra::Application
  end

  it 'has a main page' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to be_well_formed
  end

  it 'lists comics by name on the main page' do
    get '/'
    expect(last_response.body).to match(%r{<li>Dilbert.*</li>})
  end
end
