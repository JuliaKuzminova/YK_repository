puts 'Загрузка...'

require 'google/cloud/translate'
require 'httparty'

# Методы для работы с API

# Получить *последние* записи о рейтинге игроков
# Почему последние? Потому что я реализовал немного другой механизм игры
# И мой механизм не слишком хорошо соотносится с API
# Сервер хранит и отдает много записей об одном и том же игроке
# Каждый раз при сохранении рейтинга добавляется новая запись, а не обновляется предыдущая
# Поэтому из результата запроса надо специально выбирать самую последнюю запись
# Да, тут record в значении "запись", а не "рекорд", так просто совпало
def get_records
    response = HTTParty.get('http://rubyboosters.herokuapp.com/halloffame', {
        body: {
            password: '7wxrY3QcWJ+7'
        }
    })

    # Используем reverse для обратной итерации
    all_records = JSON.parse(response.body).reverse

    # Получили записи, теперь будем нормализовывать

    users = [] # Для хранения пользователей, которых мы уже выбрали
    normalized_records = [] # Результирующий список записей

    for i in 0...all_records.length
        if !users.include?(all_records[i]['user'])
            normalized_records << all_records[i]
            users << all_records[i]['user']
        end
    end

    return normalized_records
end

# Получить счет конкретного игрока
def get_score(name)
    records = get_records

    for i in 0...records.length
        return records[i]['score'] if records[i]['user'] == name
    end

    return 0
end

# Обновить счет игрока
def set_score(name, score)
    HTTParty.post('http://rubyboosters.herokuapp.com/halloffame', {
        body: {
            password: '7wxrY3QcWJ+7',
            user: name,
            score: score
        }
    })
end

# Выводит меню, возвращает код сцены
# В зависимости от кода сцены будем выбирать, какую сцену выводить (игра или рейтинг)
def show_menu
    while true
        puts '-' * 40
        puts 'Меню'
        puts '1 - играть'
        puts '2 - рейтинг'
        puts '3 - выход'

        answer = gets.chomp

        if answer == '1'
            return 'game'
        elsif answer == '2'
            return 'score'
        elsif answer == '3'
            exit
        else
            puts 'А?'
        end
    end
end

def show_game(words, translator)
    # Выбираем слово
    word = words[rand(words.length)]

    # Тут надо его перевести
    word_translated = translator.translate word, to: 'ru'

    # Строка из уже отгаданных букв
    # Здесь "тайные" буквы помечаются звездочками
    open_part = '*' * word.length

    # Реестр вводимых букв (см. ниже)
    letters = []

    # Тут храним очки
    score = word.length

    # Цикл отгадывания выбранного слова
    while true
        puts '-' * 40

        # Каждый раз надо напоминать пользователю, что он отгадывает
        # И что он уже отгадал
        puts "На русском: #{word_translated}"
        puts "На английском: #{open_part}"

        # Пользователь вводит букву
        print 'Буква или слово целиком: '
        letter = gets.chomp.downcase

        # Если длина больше единицы, то это уже совсем не буква
        # Тогда мы считаем, что пользователь пытается ввести слово целиком
        if letter.length > 1
            if letter == word.downcase
                puts 'Правильно!'
                return score + 1
            else
                puts 'Увы, ты проиграл'
                return 0
            end
        end

        # Если букву уже вводили, надо отреагировать на это
        if letters.include?(letter)
            puts "Эту букву ты уже вводил, не обманывай меня"

            # И добро пожаловать на следующую итерацию
            next
        end

        # Если буквы не было, заносим в реестр
        letters << letter

        # Перебираем отгадываемое слово и смотрим
        # Если на позиции стоит введенная буква, открываем ее
        # А если буквы в слове нет, говорим об этом

        letter_exists = false

        for i in 0...word.length
            if word[i].downcase == letter
                letter_exists = true
                open_part[i] = word[i]
            end
        end

        if letter_exists
            puts 'Умничка! Правильно!'
        else
            puts 'Не угадал...'
            score -= 1
        end

        # Если юзер закончил угадывать, выходим из игровой сцены
        if word == open_part
            puts 'Ты все угадал!'
            return score
        end
    end
end

def show_score
    puts '-' * 40

    records = get_records

    for i in 0...records.length
        puts "#{records[i]['user']}: #{records[i]['score']}"
    end

    print 'Нажми ENTER для выхода в меню...'

    # Удержать таблицу рекордов
    gets
end

# Код, вызывающий процедуры выше
words = File.readlines('noun_dictionary.txt').each { |l| l.chomp! }

# Настроить google translate
project_id = 'translation-01-220716'
key_file = 'My Project-cf8c099f9b91.json'
translator = Google::Cloud::Translate.new project: project_id, keyfile: key_file

puts 'Добро пожаловать в игру "Поле чудес на VHS"!'
puts 'Правила просты: ты отгадываешь слова по буквам, а мы начисляем тебе очки'
puts '- Очки начисляются в конце каждой сыгранной игры'
puts '- Максимальное количество очков равно количеству букв'
puts '- При ошибке снимается один балл'
puts '- Можно ввести не букву, а слово полностью, но при ошибке в таком случае игра завершается'
print 'Итак, твое имя: '
name = gets.chomp

while true
    scene = show_menu

    if scene == 'game'
        # Показываем игру, грузим очки, прибавляем очки, обновляем рейтинг
        # Так рейтинг внутри приложения всегда будет синхронизирован с сервером
        # Например, таким макаром можно играть с разных компьютеров одновременно
        earned = show_game(words, translator)
        score = get_score(name)
        set_score(name, score + earned)
    elsif scene == 'score'
        show_score
    end
end