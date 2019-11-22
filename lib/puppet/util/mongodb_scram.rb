require 'securerandom'
require 'base64'

module Puppet
  module Util
    class MongodbScram
      CLIENT_KEY = 'Client Key'.freeze
      SERVER_KEY = 'Server Key'.freeze

      attr_reader :password_hash
      attr_reader :salt
      attr_reader :iterations

      def initialize(password_hash, salt, iterations)
        @password_hash = password_hash
        @salt = salt
        @iterations = iterations
      end

      def digest
        @digest ||= OpenSSL::Digest::SHA1.new.freeze
      end

      def hash(string)
        digest.digest(string)
      end

      def hmac(data, key)
        OpenSSL::HMAC.digest(digest, data, key)
      end

      def salted_password
        OpenSSL::PKCS5.pbkdf2_hmac_sha1(
          @password_hash,
          Base64.strict_decode64(@salt),
          @iterations,
          digest.size
        )
      end

      def client_key
        hmac(salted_password, CLIENT_KEY)
      end

      def stored_key
        Base64.strict_encode64(hash(client_key))
      end

      def server_key
        Base64.strict_encode64(hmac(salted_password, SERVER_KEY))
      end
    end
  end
end
