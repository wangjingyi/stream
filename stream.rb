class Stream
  attr_writer :head, :tail
  
  def initialize(head=nil, tail=nil)
    self.head = head
    self.tail = (not empty? and not tail) ? Stream.new : tail
  end
  
  def empty?
    @head == nil
  end
  
  def throw_if_empty()
    raise "end of stream" if empty?
  end
  
  def head
    throw_if_empty
    @head
  end
  
  def tail
    throw_if_empty
    @tail = @tail.call unless @tail.is_a? Stream
    @tail
  end
  
  def self.make(head=nil, *rest)
    if head == nil
      Stream.new
    else
      Stream.new(head, ->{Stream.make *rest})
    end
  end
  
  def self.range(min, max=nil, &incr)
    incr ||= Proc.new {|x| x + 1}
    if min == max
      Stream.make min
    else
      Stream.new(min, ->{Stream.range(incr.call(min), max)})
    end
  end
  
  def skip(n)
    if n == 0 then self else tail.skip(n - 1) end
  end
  
  def item(n)
    skip(n).head
  end
  
  def walk(&f)
    return if empty?
    f.call(head)
    tail.walk &f
  end
  
  def list
    ret = []
    walk do |x|
      ret.push x
    end
    ret
  end
  
  def print
    walk {|x| puts x}
  end
  
  def map(&f)
    if empty?
      Stream.new
    else
      Stream.new(f.call(head), ->{tail.map &f})
    end
  end
  
  def filter(&f)
    if empty?
      Stream.new
    elsif f.call(head)
      Stream.new(head, ->{tail.filter &f})
    else
      tail.filter &f
    end
  end
  
  def take(n)
    return Stream.new if n == 0
    Stream.new(head, ->{tail.take(n - 1)})
  end
  
  def scale(factor) 
    f = ->(n) {n * factor}
    map &f
  end
  
  def reduce(initial, &reducer)
    if empty?
      initial
    else
      tail.reduce(reducer.call(initial, head), &reducer)
    end
  end
  
  def zip(stream, truncated=true, &zipper)
    truncated ? short_zip(stream, &zipper) : long_zip(stream, &zipper)
  end
  
  def length
    reducer = ->(sum, x) {sum + 1}
    reduce(0, &reducer)
  end
  
  def append(stream)
    if empty?
      stream
    elsif stream.empty?
      self
    else
      Stream.new head, ->{tail.append(stream)}
    end
  end
  
  def equal?(stream)
    return true if empty? and stream.empty? 
    return false if empty? or stream.empty?
    return stream.head == head && tail.equal?(stream.tail)
  end
  
  def short_zip(stream, &zipper)
    if empty? or stream.empty?
      Stream.new
    else
      Stream.new(zipper.call(head, stream.head), ->{tail.send(:short_zip, stream.tail, &zipper)})
    end
  end
  
  def long_zip(stream, &zipper)
    if empty?
      stream
    elsif stream.empty?
      self
    else
      Stream.new(zipper.call(head, stream.head), ->{tail.send(:long_zip, stream.tail, &zipper)})
    end
  end
  
  private :short_zip, :long_zip
end
