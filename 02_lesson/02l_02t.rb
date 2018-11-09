arr = File.readlines('noun_dictionary.txt').each {|l| l.chomp!}

#puts arr[0].length

def theLongestWord(a)
    i = 0
    j = 1
    while j <= a.length-1
        if a[i].length < a[j].length
            i = j
        end
        j+=1
    end
    return puts a[i]
end 

def wordL(a)
    puts "Which words legth do you want to find?"
    wordLen = gets.chomp.to_i
    i = 0
    while a[i].length != wordLen
        i+=1
    end
    return puts a[i]
end


theLongestWord(arr)

wordL(arr)