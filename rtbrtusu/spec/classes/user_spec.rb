# for rspec-puppet documentation - see http://rspec-puppet.com/tutorial/
require_relative '../spec_helper'

describe 'user', :type => :class do
it {should contain_package('mysql')}  
it do 
    should contain_file('/tmp/nishantk').with({
      'ensure' => 'directory',
      'owner'  => 'nishantk',
      'group'  => 'nishantk',
      'mode'   => '0750',
    })
  end

it do
  should contain_user('ronaldo').with ({
   'gid'    => 'ronaldo',
   'shell'  => '/bin/bash',
   'home'   => '/home/ronaldo', 
})
end
end
