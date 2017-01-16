class Species
	attr_reader(:attr_name, :attr_initial_value, :attr_maximum_age, :attr_nutritive_value, :attr_growth_per_turn)

	def initialize(name, initial_value, maximum_age, nutritive_value, growth_per_turn)
		@attr_name = name
		@attr_initial_value = initial_value
		@attr_maximum_age = maximum_age
		@attr_nutritive_value = nutritive_value
		@attr_growth_per_turn = growth_per_turn
	end

	def Species.is_valid?(attributes)
		attributes.size == 5 && attributes[0].size > 0 && attributes[1].is_integer_with_low_bound?(1) && attributes[2].is_integer_with_low_bound?(1) && attributes[3].is_integer? && attributes[4].is_integer?
	end

	def Species.new_from_array(attributes)
		new(attributes[0], attributes[1].to_i, attributes[2].to_i, attributes[3].to_i, attributes[4].to_i)
	end
end

class AnimalSpecies < Species
	attr_reader(:attr_hunger_threshold, :attr_attack_value)

	def initialize(name, initial_value, maximum_age, nutritive_value, growth_per_turn, hunger_threshold, attack_value)
		super(name, initial_value, maximum_age, nutritive_value, growth_per_turn)
		@attr_hunger_threshold = hunger_threshold
		@attr_attack_value = attack_value
	end

	def AnimalSpecies.is_valid?(attributes)
		attributes.size == 7 && super(attributes[0..attributes.size-3]) && attributes[5].is_integer_with_low_bound?(0) && attributes[6].is_integer_with_low_bound?(0)
	end

	def AnimalSpecies.new_from_array(attributes)
		new(attributes[0], attributes[1].to_i, attributes[2].to_i, attributes[3].to_i, attributes[4].to_i, attributes[5].to_i, attributes[6].to_i)
	end
end

module IncHermaphroditWithAgeSpecies
	attr_reader(:attr_switch_age)

	def initialize(name, initial_value, maximum_age, nutritive_value, growth_per_turn, hunger_threshold, attack_value, switch_age)
		super(name, initial_value, maximum_age, nutritive_value, growth_per_turn, hunger_threshold, attack_value)
		@attr_switch_age = switch_age
	end
end

module ExtHermaphroditWithAgeSpecies
	def is_valid?(attributes)
		attributes.size == 8 && super(attributes[0..attributes.size-2]) && attributes[7].is_integer_with_low_bound?(0)
	end

	def new_from_array(attributes)
		new(attributes[0], attributes[1].to_i, attributes[2].to_i, attributes[3].to_i, attributes[4].to_i, attributes[5].to_i, attributes[6].to_i, attributes[7].to_i)
	end
end

class CarnivorousSpecies < AnimalSpecies
end

class CarnivorousHermaphroditWithAgeSpecies < CarnivorousSpecies
	include IncHermaphroditWithAgeSpecies
	extend ExtHermaphroditWithAgeSpecies
end

class CarnivorousHermaphroditOpportunistSpecies < CarnivorousSpecies
end

class HerbivorousSpecies < AnimalSpecies
end

class HerbivorousHermaphroditWithAgeSpecies < HerbivorousSpecies
	include IncHermaphroditWithAgeSpecies
	extend ExtHermaphroditWithAgeSpecies
end

class HerbivorousHermaphroditOpportunistSpecies < HerbivorousSpecies
end

class OmnivorousSpecies < AnimalSpecies
end

class OmnivorousHermaphroditWithAgeSpecies < OmnivorousSpecies
	include IncHermaphroditWithAgeSpecies
	extend ExtHermaphroditWithAgeSpecies
end

class OmnivorousHermaphroditOpportunistSpecies < OmnivorousSpecies
end

class VegetalSpecies < Species
end
