# frozen_string_literal: true

class AuthenticationTokenService
    ALGORITHM_TYPE = 'RS256'
    RSA_PRIVATE = OpenSSL::PKey::RSA.generate 2048
    RSA_PUBLIC = RSA_PRIVATE.public_key
  
    def self.call
      payload = {
        "sub"=> '1234567890',
        "name"=> 'John Doe',
        "admin"=> true,
        "realm_access"=> {
          "roles"=> [
            'dgi_user'
          ]
        }
      }
  
          JWT.encode payload, RSA_PRIVATE, ALGORITHM_TYPE
      end
  end