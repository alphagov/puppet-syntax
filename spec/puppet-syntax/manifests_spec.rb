require 'spec_helper'

describe PuppetSyntax::Manifests do
  let(:subject) { PuppetSyntax::Manifests.new }

  it 'should expect an array of files' do
    expect { subject.check(nil) }.to raise_error(/Expected an array of files/)
  end

  it 'should return nothing from a valid file' do
    files = fixture_manifests('pass.pp')
    res = subject.check(files)

    res.should == []
  end

  it 'should return an error from an invalid file' do
    files = fixture_manifests('fail_error.pp')
    res = subject.check(files)
    res.grep(/Syntax error at '\}' .*:3$/).should_not == []
  end

  it 'should return a warning from an invalid file' do
    files = fixture_manifests('fail_warning.pp')
    res = subject.check(files)

    res.should have(2).items
    res[0].should match(/Unrecognised escape sequence '\\\[' .* at line 3$/)
    res[1].should match(/Unrecognised escape sequence '\\\]' .* at line 3$/)
  end

  it 'should ignore warnings about storeconfigs' do
    files = fixture_manifests('pass_storeconfigs.pp')
    res = subject.check(files)

    res.should == []
  end

  it 'should read more than one valid file' do
    files = fixture_manifests(['pass.pp', 'pass_storeconfigs.pp'])
    res = subject.check(files)

    res.should == []
  end

  it 'should continue after finding an error in the first file' do
    files = fixture_manifests(['fail_error.pp', 'fail_warning.pp'])
    res = subject.check(files)
    res.grep(/Syntax error at '\}' .*:3$/).should_not == []
    res.grep(/Unrecognised escape sequence '\\\[' .* at line 3$/).should_not == []
  end
end
