module Exceptions
  class ApiStandardError < StandardError; end
  class InvalidSlackUser < StandardError; end
  class BadSlackConnection < StandardError; end

  class ApiRequestError < ApiStandardError
    def status
      422
    end
  end

  class ApiResourceMissingError < ApiStandardError
    def status
      404
    end
  end

  class AuthTokenInvalid < ApiRequestError; end
  class ApplicationTokenInvalid < ApiRequestError; end
  class RestrictedToSelf < ApiRequestError; end
  class FounderMissing < ApiResourceMissingError; end
  class UserIsNotPendingFounder < ApiRequestError; end
  class AuthorizedUserStartupMismatch < ApiRequestError; end
  class UserPendingStartupMismatch < ApiRequestError; end
  class StartupInvalidApprovalState < ApiRequestError; end
  class UserHasPendingStartupInvite < ApiRequestError; end
  class UserHasNoPendingStartupInvite < ApiResourceMissingError; end
  class AlreadyCreatedUser < ApiRequestError; end
  class ContactAlreadyExists < ApiRequestError; end
  class InvalidPhoneNumber < ApiRequestError; end
  class FounderAlreadyHasStartup < ApiRequestError; end
  class FounderAlreadyMemberOfStartup < ApiRequestError; end
  class PhoneNumberVerificationFailed < ApiRequestError; end
  class LoginCredentialsInvalid < ApiRequestError; end
  class UserDoesNotBelongToStartup < ApiRequestError; end
  class FounderNotFound < ApiResourceMissingError; end
end
