require("./vegarium_string.rb")
require("./vegarium_simulation.rb")

if ARGV.size != 4
	STDERR.puts("Usage: #{__FILE__} <all species file> <living being file> <seed> <turns count>")
	exit false
end
if !File.exist?(ARGV[0])
	STDERR.puts("All species file #{ARGV[0]} does not exist")
	exit false
end
if !File.exist?(ARGV[1])
	STDERR.puts("Living beings file #{ARGV[1]} does not exist")
	exit false
end
if !ARGV[2].is_integer_with_low_bound?(1)
	STDERR.puts('Seed is not a positive integer')
	exit false
end
if !ARGV[3].is_integer_with_low_bound?(1)
	STDERR.puts('Turns is not a positive integer')
	exit false
end
simulation = Simulation.new(ARGV[0], ARGV[1], ARGV[2].to_i, ARGV[3].to_i)
exit simulation.load && simulation.run
