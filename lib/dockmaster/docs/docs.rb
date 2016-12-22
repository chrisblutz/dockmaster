module Dockmaster
  # This class represents processed documentation
  class Docs
    attr_reader :desc, :params, :return, :author

    def initialize(desc, params, ret, author)
      @desc = desc
      @params = params
      @return = ret
      @author = author
    end
  end
end
