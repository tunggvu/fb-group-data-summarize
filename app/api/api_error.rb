# frozen_string_literal: true

module APIError
  class Base < Grape::Exceptions::Base
    def initialize(*args)
      if args.empty?
        t_key = self.class.name.underscore.tr("/", ".")
        super message: I18n.t(t_key)
      else
        super(*args)
      end
    end
  end

  class Unauthenticated < APIError::Base
  end

  class Unauthorized < APIError::Base
  end

  class TokenExpired < APIError::Base
  end

  class WrongEmailPassword < APIError::Base
  end
end
