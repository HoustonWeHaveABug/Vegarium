require("./vegarium_simulation.rb")

if !Simulation.is_valid?(ARGV)
	exit false
end
simulation = Simulation.new(ARGV[0], ARGV[1], ARGV[2].to_i, ARGV[3].to_i)
exit simulation.load && simulation.run
