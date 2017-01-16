class LivingBeing
	attr_reader(:attr_species)

	def initialize(species, value, initial_turn, age)
		@attr_species = species
		@attr_value = value
		@attr_initial_turn = initial_turn
		@attr_age = age
		@attr_secure = true
	end

	def LivingBeing.is_valid?(attributes)
		attributes.size == 3 && attributes[0].is_integer_with_low_bound?(1) && attributes[1].is_integer_with_low_bound?(1) && attributes[2].is_integer_with_low_bound?(0)
	end

	def same_species?(species)
		@attr_species == species
	end

	def is_operational?
		@attr_value > 0
	end

	def add_value(value)
		@attr_value += value
	end

	def is_present?(turn)
		@attr_initial_turn <= turn
	end

	def is_current?
		@attr_age < @attr_species.attr_maximum_age
	end

	def is_secure?
		@attr_secure
	end

	def flag_attack
		@attr_secure = false
	end

	def is_alive?
		is_operational? && is_current?
	end

	def is_available?
		is_operational? && is_secure?
	end

	def turn_start_updates
		if is_operational?
			if is_current?
				add_value(@attr_species.attr_growth_per_turn)
				if !is_operational?
					puts("# #{full_name} dies of starvation")
				end
			else
				puts("# #{full_name} dies of old age")
			end
		end
	end

	def is_target?(animal)
		self != animal && is_operational?
	end

	def random_target(living_beings, living_beings_count)
		index_rand = rand(living_beings_count)
		index = index_rand
		while index < living_beings_count && !living_beings[index].is_target?(self)
			index += 1
		end
		if index == living_beings_count
			index = 0
			while index < index_rand && !living_beings[index].is_target?(self)
				index += 1
			end
			if index == index_rand
				nil
			else
				living_beings[index]
			end
		else
			living_beings[index]
		end
	end

	def turn_end_updates
		@attr_age += 1
		@attr_secure = true
	end

	def LivingBeing.output_header
		puts('#')
		print('# Species, Value, Initial turn, Age')
	end

	def output
		print("#{@attr_species.attr_name}, #{@attr_value}, #{@attr_initial_turn}, #{@attr_age}")
	end

	private :is_current?, :is_secure?, :random_target
	protected :same_species?, :add_value, :flag_attack, :is_target?
end

class Animal < LivingBeing
	@@sex_lookup = [
		'M',
		'F'
	]

	@@sex_switch_lookup = {
		'M' => 'F',
		'F' => 'M'
	}

	def initialize(species, value, initial_turn, age, name, sex)
		super(species, value, initial_turn, age)
		@attr_name = name
		@attr_sex = sex
	end

	def Animal.is_valid?(attributes)
		attributes.size == 5 && super(attributes[0..attributes.size-3]) && attributes[3].size > 0 && @@sex_switch_lookup[attributes[4]] != nil
	end

	def Animal.new_from_array(species, attributes)
		new(species, attributes[0].to_i, attributes[1].to_i, attributes[2].to_i, attributes[3], attributes[4])
	end

	def is_hungry?
		@attr_value <= @attr_species.attr_hunger_threshold
	end

	def full_name
		@attr_name+' ('+@attr_species.attr_name+', '+@attr_sex+')'
	end

	def same_sex?(sex)
		@attr_sex == sex
	end

	def sex_switch
		puts("# #{full_name} switches to #{@@sex_switch_lookup[@attr_sex]}")
		@attr_sex = @@sex_switch_lookup[@attr_sex]
	end

	def attack(living_beings, living_beings_count)
		living_being = random_target(living_beings, living_beings_count)
		if living_being != nil && !living_being.same_species?(@attr_species)
			puts("# #{full_name} attacks #{living_being.full_name}")
			add_value(living_being.attr_species.attr_nutritive_value)
			if !is_operational?
				puts("# #{full_name} dies after poisonous meal")
			end
			living_being.add_value(-@attr_species.attr_attack_value)
			if !living_being.is_operational?
				puts("# #{living_being.full_name} dies after being attacked")
			end
			living_being.flag_attack
		end
	end

	def is_partner?(animal)
		self != animal && animal.same_species?(@attr_species) && !is_hungry? && is_secure?
	end

	def new_child(partner, name, turn)
		puts("# #{full_name} reproduces with #{partner.full_name}")
		child = self.class.new(@attr_species, @attr_species.attr_initial_value, turn, 0, name, @@sex_lookup[rand(@@sex_lookup.size)])
		puts("# Their child is #{child.full_name}")
		child.turn_start_updates
		child
	end

	def reproduce_with(animals, animals_count, child_name, turn)
		animal = random_target(animals, animals_count)
		if animal.is_partner?(self) && !animal.same_sex?(@attr_sex)
			new_child(animal, child_name, turn)
		else
			nil
		end
	end

	def Animal.output_header
		puts('#')
		puts('# ANIMALS')
		super
		puts(', Name, Sex')
		@@attr_records_count = 0
	end

	def output
		super
		puts(", #{@attr_name}, #{@attr_sex}")
		@@attr_records_count += 1
	end

	def Animal.output_footer
		puts('#')
		puts("# Animals count #{@@attr_records_count}")
	end

	private :sex_switch, :new_child
	protected :same_sex?, :is_partner?
end

module IncCarnivorous
	def attack(animals, animals_count, vegetals, vegetals_count)
		super(animals, animals_count)
	end
end

module IncHerbivorous
	def attack(animals, animals_count, vegetals, vegetals_count)
		super(vegetals, vegetals_count)
	end
end

module IncOmnivorous
	def attack(animals, animals_count, vegetals, vegetals_count)
		super(animals+vegetals, animals_count+vegetals_count)
	end
end

module IncHermaphroditWithAge
	def turn_start_updates
		super
		if is_alive? && @attr_species.attr_switch_age == @attr_age
			sex_switch
		end
	end
end

module IncHermaphroditOpportunist
	def reproduce_with(animals, animals_count, child_name, turn)
		animal = random_target(animals, animals_count)
		if animal.is_partner?(self)
			if animal.same_sex?(@attr_sex)
				sex_switch
			end
			new_child(animal, child_name, turn)
		else
			nil
		end
	end
end

class Carnivorous < Animal
	include IncCarnivorous
end

class CarnivorousHermaphroditWithAge < Carnivorous
	include IncHermaphroditWithAge
end

class CarnivorousHermaphroditOpportunist < Carnivorous
	include IncHermaphroditOpportunist
end

class Herbivorous < Animal
	include IncHerbivorous
end

class HerbivorousHermaphroditWithAge < Herbivorous
	include IncHermaphroditWithAge
end

class HerbivorousHermaphroditOpportunist < Herbivorous
	include IncHermaphroditOpportunist
end

class Omnivorous < Animal
	include IncOmnivorous
end

class OmnivorousHermaphroditWithAge < Omnivorous
	include IncHermaphroditWithAge
end

class OmnivorousHermaphroditOpportunist < Omnivorous
	include IncHermaphroditOpportunist
end

class Vegetal < LivingBeing
	def initialize(species, value, initial_turn, age, quantity)
		super(species, value, initial_turn, age)
		@attr_quantity = quantity
	end

	def Vegetal.is_valid?(attributes)
		attributes.size == 4 && super(attributes[0..attributes.size-2]) && attributes[3].is_integer_with_low_bound?(1)
	end

	def Vegetal.new_from_array(species, attributes)
		new(species, attributes[0].to_i, attributes[1].to_i, attributes[2].to_i, 1)
	end

	def full_name
		'One '+@attr_species.attr_name
	end

	def group_key
		[ @attr_species.attr_name, @attr_value, @attr_initial_turn, @attr_age ]
	end

	def add_quantity(quantity)
		@attr_quantity += quantity
	end

	def reproduce(turn)
		if @attr_value >= @attr_species.attr_initial_value*2
			add_value(-@attr_species.attr_initial_value)
			puts("# #{full_name} reproduces")
			child = self.class.new(@attr_species, @attr_species.attr_initial_value, turn, 0, 1)
			child.turn_start_updates
			child
		else
			nil
		end
	end

	def Vegetal.output_header
		puts('#')
		puts('# VEGETALS')
		super
		puts(', Quantity')
		@@attr_records_count = 0
	end

	def output
		super
		puts(", #{@attr_quantity}")
		@@attr_records_count += @attr_quantity
	end

	def Vegetal.output_footer
		puts('#')
		puts("# Vegetals count #{@@attr_records_count}")
	end
end
