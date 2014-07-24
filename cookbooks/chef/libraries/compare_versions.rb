class Chef
  class Util
    def self.compare_versions(a, b)
      if a.kind_of?(String)
        a = a.split(".").map { |c| c.to_i }
      end

      if b.kind_of?(String)
        b = b.split(".").map { |c| c.to_i }
      end

      a <=> b
    end
  end
end
