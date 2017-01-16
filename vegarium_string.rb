class String
	def is_integer?
		begin
			if Integer(self)
			end
		rescue
			false
		else
			true
		end
	end

	def is_integer_with_low_bound?(low_bound)
		is_integer? && self.to_i >= low_bound
	end
end
