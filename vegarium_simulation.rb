require("./vegarium_string.rb")
require("./vegarium_species.rb")
require("./vegarium_living_being.rb")

class Simulation
	@@species_class_lookup = {
		'Carnivorous' => CarnivorousSpecies,
		'CarnivorousHermaphroditWithAge' => CarnivorousHermaphroditWithAgeSpecies,
		'CarnivorousHermaphroditOpportunist' => CarnivorousHermaphroditOpportunistSpecies,
		'Herbivorous' => HerbivorousSpecies,
		'HerbivorousHermaphroditWithAge' => HerbivorousHermaphroditWithAgeSpecies,
		'HerbivorousHermaphroditOpportunist' => HerbivorousHermaphroditOpportunistSpecies,
		'Omnivorous' => OmnivorousSpecies,
		'OmnivorousHermaphroditWithAge' => OmnivorousHermaphroditWithAgeSpecies,
		'OmnivorousHermaphroditOpportunist' => OmnivorousHermaphroditOpportunistSpecies,
		'Vegetal' => VegetalSpecies
	}

	@@living_being_class_lookup = {
		CarnivorousSpecies => Carnivorous,
		CarnivorousHermaphroditWithAgeSpecies => CarnivorousHermaphroditWithAge,
		CarnivorousHermaphroditOpportunistSpecies => CarnivorousHermaphroditOpportunist,
		HerbivorousSpecies => Herbivorous,
		HerbivorousHermaphroditWithAgeSpecies => HerbivorousHermaphroditWithAge,
		HerbivorousHermaphroditOpportunistSpecies => HerbivorousHermaphroditOpportunist,
		OmnivorousSpecies => Omnivorous,
		OmnivorousHermaphroditWithAgeSpecies => OmnivorousHermaphroditWithAge,
		OmnivorousHermaphroditOpportunistSpecies => OmnivorousHermaphroditOpportunist,
		VegetalSpecies => Vegetal
	}

	def initialize(all_species_file, living_beings_file, seed, turns_count)
		@attr_all_species_file = all_species_file
		@attr_living_beings_file = living_beings_file
		@attr_seed = seed
		@attr_turns_count = turns_count
		@attr_all_species = {}
		@attr_animals = {}
		@attr_vegetals = {}
		@attr_sequence = 0
	end

	def Simulation.is_valid?(attributes)
		if attributes.size != 4
			STDERR.puts("Invalid number of attributes for this simulation")
			STDERR.puts("Expected attributes are <all species file> <living being file> <seed> <turns count>")
			return false
		end
		if !File.exist?(attributes[0])
			STDERR.puts("All species file #{attributes[0]} does not exist")
			return false
		end
		if !File.exist?(attributes[1])
			STDERR.puts("Living beings file #{attributes[1]} does not exist")
			return false
		end
		if !attributes[2].is_integer_with_low_bound?(1)
			STDERR.puts('Seed is not a positive integer')
			return false
		end
		if !attributes[3].is_integer_with_low_bound?(1)
			STDERR.puts('Turns count is not a positive integer')
			return false
		end
		true
	end

	def load_species(attributes, file_line)
		begin
			if @@species_class_lookup[attributes[0]] == nil
				STDERR.puts("Invalid species class \"#{attributes[0]}\" at line #{file_line} in file #{@attr_all_species_file}")
				return false
			end
			if !@@species_class_lookup[attributes[0]].is_valid?(attributes[1..attributes.size-1])
				STDERR.puts("Invalid species attributes at line #{file_line} in file #{@attr_all_species_file}")
				return false
			end
			if @attr_all_species[attributes[1]] != nil
				STDERR.puts("Duplicate species \"#{attributes[1]}\" at line #{file_line} in file #{@attr_all_species_file}")
				return false
			end
			@attr_all_species[attributes[1]] = @@species_class_lookup[attributes[0]].new_from_array(attributes[1..attributes.size-1])
		rescue Exception => exception
			STDERR.puts("Exception \"#{exception}\" rescued in method #{self.class}.#{__method__}")
			STDERR.puts(exception.backtrace)
			false
		else
			true
		end
	end

	def load_all_species
		begin
			lines = File.readlines(@attr_all_species_file)
			file_line = 0
			for line in lines
				file_line += 1
				if line[0, 1] != '#' && !load_species(line.chomp.split(', '), file_line)
					return false
				end
			end
		rescue Exception => exception
			STDERR.puts("Exception \"#{exception}\" rescued in method #{self.class}.#{__method__}")
			STDERR.puts(exception.backtrace)
			false
		else
			true
		end
	end

	def load_living_being(attributes, file_line)
		begin
			if @attr_all_species[attributes[0]] == nil
				STDERR.puts("Species \"#{attributes[0]}\" does not exist at line #{file_line} in file #{@attr_living_beings_file}")
				return false
			end
			living_being_class = @@living_being_class_lookup[@attr_all_species[attributes[0]].class]
			if !living_being_class.is_valid?(attributes[1..attributes.size-1])
				STDERR.puts("Invalid living being attributes at line #{file_line} in file #{@attr_living_beings_file}")
				return false
			end
			if living_being_class == Vegetal
				(1..attributes[4].to_i).each do
					@attr_vegetals[@attr_sequence.to_s] = living_being_class.new_from_array(@attr_all_species[attributes[0]], attributes[1..attributes.size-2])
					@attr_sequence += 1
				end
			else
				if @attr_animals[attributes[4]] != nil
					STDERR.puts("Duplicate animal \"#{attributes[4]}\" at line #{file_line} in file #{@attr_living_beings_file}")
					return false
				end
				@attr_animals[attributes[4]] = living_being_class.new_from_array(@attr_all_species[attributes[0]], attributes[1..attributes.size-1])
			end
		rescue Exception => exception
			STDERR.puts("Exception \"#{exception}\" rescued in method #{self.class}.#{__method__}")
			STDERR.puts(exception.backtrace)
			false
		else
			true
		end
	end

	def load_living_beings
		begin
			lines = File.readlines(@attr_living_beings_file)
			file_line = 0
			for line in lines
				file_line += 1
				if line[0, 1] != '#' && !load_living_being(line.chomp.split(', '), file_line)
					return false
				end
			end
		rescue Exception => exception
			STDERR.puts("Exception \"#{exception}\" rescued in method #{self.class}.#{__method__}")
			STDERR.puts(exception.backtrace)
			false
		else
			true
		end
	end

	def load
		load_all_species && load_living_beings
	end

	def turn_start(turn, living_beings)
		turn_living_beings = []
		turn_living_beings_count = 0
		for living_being in living_beings
			if living_being[1].is_present?(turn)
				living_being[1].turn_start_updates
				if living_being[1].is_alive?
					turn_living_beings[turn_living_beings_count] = living_being[1]
					turn_living_beings_count += 1
				else
					living_beings.delete(living_being[0])
				end
			end
		end
		return turn_living_beings, turn_living_beings_count
	end

	def add_living_being(living_being, turn_living_beings, turn_living_beings_count, living_beings)
		if living_being != nil
			turn_living_beings[turn_living_beings_count] = living_being
			turn_living_beings_count += 1
			living_beings[@attr_sequence.to_s] = living_being
			@attr_sequence += 1
		end
		turn_living_beings_count
	end

	def run_turn(turn)
		begin
			puts('#')
			puts("# START OF TURN #{turn} - EVENTS")
			turn_animals, turn_animals_count = turn_start(turn, @attr_animals)
			turn_vegetals, turn_vegetals_count = turn_start(turn, @attr_vegetals)
			puts('#')
			puts("# TURN #{turn} - EVENTS")
			index = 0
			while index < turn_animals_count
				if turn_animals[index].is_available?
					if turn_animals[index].is_hungry?
						turn_animals[index].attack(turn_animals, turn_animals_count, turn_vegetals, turn_vegetals_count)
					else
						turn_animals_count = add_living_being(turn_animals[index].reproduce_with(turn_animals, turn_animals_count, @attr_sequence.to_s, turn), turn_animals, turn_animals_count, @attr_animals)
					end
				end
				index += 1
			end
			index = 0
			while index < turn_vegetals_count
				if turn_vegetals[index].is_available?
					turn_vegetals_count = add_living_being(turn_vegetals[index].reproduce(turn), turn_vegetals, turn_vegetals_count, @attr_vegetals)
				end
				index += 1
			end
			puts('#')
			puts("# END OF TURN #{turn} - STATE")
			Animal.output_header
			for animal in turn_animals
				animal.turn_end_updates
				if animal.is_operational?
					animal.output
				end
			end
			Animal.output_footer
			turn_vegetal_groups = {}
			for vegetal in turn_vegetals
				vegetal.turn_end_updates
				if vegetal.is_operational?
					vegetal_group_key = vegetal.group_key
					if turn_vegetal_groups[vegetal_group_key] == nil
						turn_vegetal_groups[vegetal_group_key] = vegetal.clone
					else
						turn_vegetal_groups[vegetal_group_key].add_quantity(1)
					end
				end
			end
			Vegetal.output_header
			for vegetal in turn_vegetal_groups
				vegetal[1].output
			end
			Vegetal.output_footer
		rescue Exception => exception
			STDERR.puts("Exception \"#{exception}\" rescued in method #{self.class}.#{__method__}")
			STDERR.puts(exception.backtrace)
			false
		else
			true
		end
	end

	def run
		begin
			srand(@attr_seed)
			for turn in (1..@attr_turns_count)
				if !run_turn(turn)
					return false
				end
			end
		rescue Exception => exception
			STDERR.puts("Exception \"#{exception}\" rescued in method #{self.class}.#{__method__}")
			STDERR.puts(exception.backtrace)
			false
		else
			true
		end
	end

	private :load_species, :load_all_species, :load_living_being, :load_living_beings, :turn_start, :add_living_being, :run_turn
end
