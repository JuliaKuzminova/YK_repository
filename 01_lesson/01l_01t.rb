puts "How many rubels do you have?"
my_rubles = gets.chomp.to_f

while my_rubles <= 0 
    puts "Enter a number greater than zero:" 
    my_rubles = gets.chomp.to_f
end
puts "You have #{(my_rubles/65.2).round} dollars or #{(my_rubles/75.3).round} evro or #{(my_rubles/85.3).round} pounds"