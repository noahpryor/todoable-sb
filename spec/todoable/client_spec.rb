# frozen_string_literal: true

require 'spec_helper'

describe Todoable::Client do
  let(:username) { 'username' }
  let(:password) { 'password' }

  describe '::new' do
    it 'raises an error when initiliazed without a username' do
      expect { described_class.new(password: password) }
        .to raise_error(ArgumentError)
    end

    it 'raises an error when initiliazed without a password' do
      expect { described_class.new(username: username) }
        .to raise_error(ArgumentError)
    end

    it 'initializes a client with username and password' do
      client = described_class.new(username: username, password: password)
      expect(client.is_a?(described_class)).to be(true)
    end
  end

  describe '#authenticate' do
    let(:auth_hash) { { username: username, password: password } }
    let(:client) { described_class.new(auth_hash) }
    let(:endpoint) { '/authenticate' }
    let(:options)  { { basic_auth: auth_hash } }

    context 'with an initialized client' do
      it 'calls the authenticate endpoint' do
        allow(client.class).to receive(:post)
          .and_call_original
        client.authenticate
        expect(client.class).to have_received(:post)
          .with(endpoint, options)
      end

      it 'sets the authentication token' do
        client.authenticate
        expect(client.token.is_a?(String)).to be(true)
      end
    end
  end

  describe '::build' do
    let(:client) do
      described_class.new(username: username, password: password)
    end

    it 'raises an error when called without a username' do
      expect { described_class.build(password: password) }
        .to raise_error(ArgumentError)
    end

    it 'raises an error when called without a password' do
      expect { described_class.build(username: username) }
        .to raise_error(ArgumentError)
    end

    it 'initializes a client with username and password' do
      allow(described_class).to receive(:new)
        .and_return(client)
      described_class.build(username: username, password: password)
      expect(described_class).to have_received(:new)
        .with(username: username, password: password)
    end

    it 'authenticates a client' do
      allow(described_class).to receive(:new).and_return(client)
      allow(client).to receive(:authenticate)
      described_class.build(username: username, password: password)
      expect(client).to have_received(:authenticate).once
    end
  end
end
