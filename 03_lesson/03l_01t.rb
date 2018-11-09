def translating(a)
    require "google/cloud/translate"

    # Your Google Cloud Platform project ID
    project_id = "translation-01-220716"
    key_file = "My Project-cf8c099f9b91.json"

    # Instantiates a client
    translate = Google::Cloud::Translate.new project: project_id, keyfile: key_file

    # The text to translate
    text = a
    # The target language
    target = "ru"

    # Translates some text into Russian
    translation = translate.translate text, to: target

    #puts "Text: #{text}"
    return translation
end

def yes(a)
    a.length.times do print '*'
    puts 'Введите перевод слова:'
    trn = gets.chomp
    if trn == a
        puts "Верно!"
    elsif trn!= a
        puts "Неверно"
    end
end

def no(a)
    str = a.length.times do print '*'
    
    #arr = Array.new(a.length) 
    
    
    


eng = File.readlines('noun_dictionary.txt').each {|l| l.chomp!}
i = rand(eng.length)
rus = translating(eng[i])

puts "Слово '#{rus}'"

puts "Хотите угадать слово целиком (введите: yes) или по буквам (нажмите enter)?"

answer = gets.chomp

if answer == yes
    yes(eng[i])
elsif answer != yes
    no(eng[i])

end