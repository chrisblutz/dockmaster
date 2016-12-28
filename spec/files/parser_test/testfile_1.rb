module TestFiles
  module_function

  def mod_method; end

  # Test documentation for TestFile1
  #
  # @author test(1)
  class TestFile1
    # A field (1)
    TEST1 = 'test'.freeze

    # A non-constant field (1)
    attr_reader :test_field

    # A method (1)
    #
    # @param test desc(1)
    # @return test(1)
    def test_method_1(test); end

    class << self
      # A static non-constant field (1)
      attr_reader :stest_field

      # A static method (1)
      def stest_method_1(test); end

      private

      # A private static method (1)
      def ptest_method_1(test); end
    end
  end
end
