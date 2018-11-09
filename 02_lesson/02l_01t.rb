puts "Сумма кредита?"
credit = gets.chomp.to_f

puts "Процент по кредиту"
percent = gets.chomp.to_f

puts "Введите 0, если хотите ввести сумму ежемесячного платежа, или 1, если хотите ввести срок погашения кредита"

choosing = gets.chomp.to_i

if choosing == 0
  puts "Введите сумму ежемесячного платежа:"
  month_amount = gets.chomp.to_f
  i = 0
  while credit > 0
    i+=1
    credit += credit*percent*0.01/12 - month_amount
  end
  puts "Срок погашения кредита #{(i-1).div 12} лет\года и #{(i-1) % 12} месяц\-ев"
elsif choosing == 1
  puts "Введите срок погашения кредита в месяцах:"
  months = gets.chomp.to_f
  puts "Сумма ежемесячного платежа: #{credit*percent*0.01*(1 + percent*0.01/12)**months/12/((1 + percent*0.01/12)**months - 1)}."
end
  