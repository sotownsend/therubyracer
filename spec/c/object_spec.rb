require 'c_spec_helper'

describe V8::C::Object do
  requires_v8_context

  it 'can create a new object' do
    expect(V8::C::Object.New(@isolate)).to be
  end

  it 'can store and retrieve a value' do
    o = V8::C::Object.New(@isolate)
    key = V8::C::String.NewFromUtf8(@isolate, 'foo')
    value = V8::C::String.NewFromUtf8(@isolate, 'bar')

    expect(o.Set(@ctx, key, value)).to be_successful
    expect(o.Get(@ctx, key)).to strict_eq value
  end

  it 'can determine if a key has been set' do
    o = V8::C::Object.New(@isolate)
    key = V8::C::String.NewFromUtf8(@isolate, 'foo')

    expect(o.Set(@ctx, key, key)).to be_successful
    expect(o.Has(@ctx, key)).to be_successful
  end

  it 'can delete keys' do
    o = V8::C::Object.New(@isolate)
    key = V8::C::String.NewFromUtf8(@isolate, 'foo')

    expect(o.Set(@ctx, key, key)).to be_successful
    expect(o.Delete(@ctx, key)).to be_successful
    expect(o.Has(@ctx, key)).to eq_just false
  end

  describe '#SetAccessor' do
    it 'can set getters' do
      o = V8::C::Object.New(@isolate)
      key = V8::C::String.NewFromUtf8(@isolate, 'foo')

      data = V8::C::String.NewFromUtf8(@isolate, 'data')
      get_value = V8::C::String.NewFromUtf8(@isolate, 'bar')

      get_name = nil
      get_data = nil

      getter = proc do |name, info|
        get_name = name
        get_data = info.Data

        info.GetReturnValue.Set(get_value)
      end

      expect(o.SetAccessor(@ctx, key, getter, nil, data)).to be_successful
      expect(o.Get(@ctx, key)).to strict_eq get_value

      expect(get_name).to v8_eq key
      expect(get_data).to strict_eq data
    end

    it 'can set setters' do
      o = V8::C::Object.New(@isolate)
      key = V8::C::String.NewFromUtf8(@isolate, 'foo')
      data = V8::C::String.NewFromUtf8(@isolate, 'data')

      set_value = nil
      set_data = nil

      setter = proc do |name, value, info|
        set_data = info.Data

        set_value = value
      end

      expect(o.SetAccessor(@ctx, key, proc { }, setter, data)).to be_successful

      expect(o.Set(@ctx, key, data)).to be_successful

      expect(set_data).to strict_eq data
      expect(set_value).to strict_eq data
    end
  end

  describe '#CreateDataProperty' do
    it 'can set the property' do
      o = V8::C::Object.New(@isolate)
      key = V8::C::String.NewFromUtf8(@isolate, 'foo')
      data = V8::C::String.NewFromUtf8(@isolate, 'data')

      expect(o.CreateDataProperty(@ctx, key, data)).to be_successful
      expect(o.Get(@ctx, key)).to be_successful
    end
  end

  describe '#DefineOwnProperty' do
    it 'can set the property' do
      o = V8::C::Object.New(@isolate)
      key = V8::C::String.NewFromUtf8(@isolate, 'foo')
      data = V8::C::String.NewFromUtf8(@isolate, 'data')

      expect(o.DefineOwnProperty(@ctx, key, data)).to be_successful
      expect(o.Get(@ctx, key)).to be_successful
    end
  end

  describe '#GetPropertyAttributes' do
    it 'can get the set attributes' do
      o = V8::C::Object.New(@isolate)
      key = V8::C::String.NewFromUtf8(@isolate, 'foo')
      data = V8::C::String.NewFromUtf8(@isolate, 'data')

      expect(o.DefineOwnProperty(@ctx, key, data, V8::C::PropertyAttribute::DontEnum)).to be_successful
      expect(o.GetPropertyAttributes(@ctx, key)).to eq_just V8::C::PropertyAttribute::DontEnum
    end
  end

  # TODO: Enable this when the methods are implemented in the extension
  # it 'can retrieve all property names' do
  #   o = V8::C::Object.New
  #   o.Set(V8::C::String.New('foo'), V8::C::String.New('bar'))
  #   o.Set(V8::C::String.New('baz'), V8::C::String.New('bang'))
  #
  #   names = o.GetPropertyNames()
  #   names.Length().should eql 2
  #   names.Get(0).Utf8Value().should eql 'foo'
  #   names.Get(1).Utf8Value().should eql 'baz'
  # end
  #
  # it 'can set an accessor from ruby' do
  #   o = V8::C::Object.New
  #   property = V8::C::String.New('statement')
  #   callback_data = V8::C::String.New('I am Legend')
  #   left = V8::C::String.New('Yo! ')
  #   getter = proc do |name, info|
  #     info.This().StrictEquals(o).should be_true
  #     info.Holder().StrictEquals(o).should be_true
  #     V8::C::String::Concat(left, info.Data())
  #   end
  #   setter = proc do |name, value, info|
  #     left = value
  #   end
  #   o.SetAccessor(property, getter, setter, callback_data)
  #   o.Get(property).Utf8Value().should eql 'Yo! I am Legend'
  #   o.Set(property, V8::C::String::New('Bro! '))
  #   o.Get(property).Utf8Value().should eql 'Bro! I am Legend'
  # end
end
