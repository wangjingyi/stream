require File.expand_path(File.dirname(__FILE__) + '/stream')
require 'test/unit'

class TestStream < Test::Unit::TestCase
  def test_head
    stream = Stream.make 1, 2, 3, 4
    assert_equal(1, stream.head)
    assert_equal(1, stream.item(0))
    assert_equal(2, stream.item(1))
    assert_equal(4, stream.item(3))
  end
  
  def test_tail
    stream = Stream.make 1, 2, 3, 4
    assert_equal(2, stream.tail.head)
  end
  
  def test_empty_stream
    stream = Stream.make
    assert_raise(RuntimeError) {stream.head}
    
    stream = Stream.make 1
    assert_equal(stream.head, 1)
    assert_raise(RuntimeError) {stream.tail.head}
  end
  
  def test_range
    stream = Stream.range 0
    
    assert_equal(0, stream.head)
    assert_equal(1, stream.item(1))
    assert_equal(10, stream.item(10))
  end
  
  def test_range2
    stream = Stream.range(0, 10)
    assert_equal(11, stream.length)
  end
  #def test_walk
  #  stream = Stream.make 1, 2, 3, 4
  #  stream.walk {|x| puts x}
  #  assert_equal(1, 1)
  #end
  def test_list
    stream = Stream.make 1, 2, 3, 4
    assert_equal([1, 2, 3, 4], stream.list)
    stream = Stream.new
    assert_equal([], stream.list)
  end
  
  def test_map
    stream = Stream.make 1, 2, 3, 4
    stream2 = stream.map {|x| x * 2}
    assert_equal(2, stream2.head)
    assert_equal(8, stream2.item(3))
  end
  
  def test_member
    stream = Stream.make 1, 2, 3, 4
    assert_equal(true, stream.member(3))
    assert_equal(true, stream.member(4))
    assert_equal(true, stream.member(1))
    assert_equal(false, stream.member(5))
    stream = Stream.make()
    assert_equal(false, stream.member(3))
    assert_equal(false, stream.member(1))
  end
  
  def test_filter
    stream = Stream.make 1, 2, 3, 4
    is_odd = ->(x) { x % 2 == 0}
    stream2 = stream.filter(&is_odd)
    assert_equal(2, stream2.head)
    assert_equal(4, stream2.item(1))
  end
  
  def test_take
    stream = Stream.make 1, 2, 3, 4, 5
    stream2 = stream.take 2
    assert_equal(1, stream2.head)
    assert_equal(2, stream2.item(1))
    assert_raise(RuntimeError) {stream2.item(2)}
  end
  
  def test_scale
    stream = Stream.make 1, 2, 3, 4
    stream2 = stream.scale 5
    assert_equal(5, stream2.head)
    assert_equal(20, stream2.item(3))
  end
  
  def test_reduce
    stream = Stream.make 1, 2, 3, 4
    sum = stream.reduce(0) {|x, y| x + y }
    assert_equal(10, sum)
    product = stream.reduce(1) {|x, y| x * y }
    assert_equal(24, product)
  end
  
  def test_length
    stream = Stream.make 1, 2, 3, 4, 5
    assert_equal(5, stream.length)
    stream = Stream.new
    assert_equal(0, stream.length)
  end
  
  def test_equal
    s1 = Stream.new
    s2 = Stream.new
    assert_equal(true, s1.equal?(s2))
    
    s1 = Stream.make 1, 2, 3
    s2 = Stream.make 1, 2, 3
    assert_equal(true, s1.equal?(s2))
    
    s1 = Stream.make 1
    s2 = Stream.make 1, 2
    assert_equal(false, s1.equal?(s2))
  end
  
  def test_append
    s1 = Stream.make 1, 2, 3, 4
    s2 = Stream.make 5, 6, 7
    s = s1.append s2
    assert_equal(7, s.length)
    assert_equal(1, s.item(0))
    assert_equal(7, s.item(6))
    assert_raise(RuntimeError) {s.item 7}
  end
  
  def test_zip
    s1 = Stream.make 1, 2, 3, 4
    s2 = Stream.make 2, 3, 4
    
    s = s1.zip(s2) {|x, y| x + y }
    assert_equal(3, s.head)
    assert_equal(5, s.item(1))
    assert_equal(3, s.length)
    
    s = s1.zip(s2, false) {|x, y| x + y }
    assert_equal(3, s.head)
    assert_equal(5, s.item(1))
    assert_equal(4, s.length)
    assert_equal(4, s.item(3))
  end
  
  def test_hard   
    sieve = ->(recurse, s) do
      h = s.head
      l = ->{ recurse.call(recurse, s.tail.filter{|x| x % h != 0}) }     
      Stream.new(h, l)
    end
    
    ans = sieve.call(sieve, Stream.range(2)).take(10)
    ten_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    assert_equal(ten_primes, ans.list)
  end
end