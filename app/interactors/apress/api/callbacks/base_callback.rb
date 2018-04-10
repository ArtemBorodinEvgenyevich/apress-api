module Apress
  module Api
    module Callbacks
      class BaseCallback
        include Interactor

        def self.retry_exceptions
          @retry_exceptions ||= Set.new
        end

        def self.add_retry_exceptions(*errors)
          retry_exceptions.merge(errors)
        end

        def self.inherited(other)
          other.around do |interactor|
            begin
              interactor.call
            rescue Exception => error
              if self.class.retry_exceptions.any? { |ex| error.is_a?(Class) && ex >= error || ex === error }
                raise Apress::Api::Callbacks::FireCallbackError.new(error.message, error.backtrace)
              else
                raise error
              end
            end
          end
        end
      end
    end
  end
end
