=begin

The method lookup path is the order of where Ruby will look for a method when it's called. It starts in the current class, looks in any mixed in modules (starting at the module mixed in lowest in the class definition, then works its way up), then looks in the superclass repeating the process until the method definition is found or a no method error is thrown.

LS wording: The method lookup path is the order in which Ruby will traverse the class heirarchy to look for methods to invoke. We can use the #ancestors method to see the method lookup path for a certain class.

=end