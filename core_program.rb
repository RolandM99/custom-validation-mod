require './test'

test = {}
test[:case1] = TestClass.new(nil, 23, 'manful@gmail.com')
test[:case2] = TestClass.new('Roland', nil, 'manful1@gmail.com')
test[:case3] = TestClass.new('Roland', 23, 'manful23@gmail.com')
test[:case4] = TestClass.new('Roland', 23, 'ma\\nful1@gmail.com')
test[:case5] = TestClass.new('Roland28', 23, 'manful@gmail.com')

test[:case6] = TestClass.new('Roland', 23, 125)
test[:case7] = TestClass.new('Roland', '22', 125)

puts "Validation of a valid object #{test[:case3].valid?} "
puts "Validation of an invalid object with presence #{test[:case1].valid?}, #{test[:case2].valid?} "
puts "Validation of an invalid object with format   #{test[:case4].valid?}, #{test[:case5].valid?} "
puts "Validation of an invalid object with type     #{test[:case6].valid?}, #{test[:case7].valid?} "

test.each_pair do |_k, v|
  v.validate!
rescue StandardError => e
  puts e.to_s
end
