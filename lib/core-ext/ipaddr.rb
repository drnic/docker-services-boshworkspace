class IPAddr
  def reject(range)
    left_start = self.to_range.first
    left_end = left_start
    left_next = left_start.succ
    total_considered = 1
    until (total_considered > self.to_range.to_a.size) || left_next.to_s == range.to_s
      left_end = left_next
      left_next = left_next.succ
      total_considered += 1
    end
    left_range = [left_start, left_end]

    right_start = range.to_range.last.succ
    right_end = self.to_range.last
    right_right = [right_start, right_end]

    [left_range, right_right]
  end
end
