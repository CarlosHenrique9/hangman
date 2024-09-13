# Função para carregar o dicionário de palavras
def load_dictionary
  words = []
  File.open("dictionary.txt", "r") do |file|
    words = file.readlines.map(&:chomp)
  end
  words.select { |word| word.length.between?(5, 12) }
end

# Função para escolher uma palavra aleatória
def pick_random_word(words)
  words.sample
end

# Função para exibir o progresso da palavra com as letras adivinhadas
def display_progress(word, correct_guesses)
  word.chars.map { |char| correct_guesses.include?(char) ? char : "_" }.join(" ")
end

# Função para receber uma adivinhação do jogador
def make_guess(guesses)
  puts "Digite uma letra (ou 'save' para salvar o jogo): "
  input = gets.chomp.downcase

  if input == "save"
    return "save"
  elsif guesses.include?(input)
    puts "Você já adivinhou essa letra!"
  else
    guesses << input
  end
  input
end

# Função para salvar o jogo
def save_game(state)
  File.open("save_file", "w") { |file| Marshal.dump(state, file) }
end

# Função para carregar o jogo salvo
def load_game
  if File.exist?("save_file")
    File.open("save_file", "r") { |file| Marshal.load(file) }
  else
    nil
  end
end

# Função principal do jogo
def play_game
  game_state = load_game

  if game_state
    puts "Jogo salvo encontrado! Deseja continuar? (s/n)"
    answer = gets.chomp.downcase
    if answer == 's'
      secret_word = game_state[:secret_word]
      correct_guesses = game_state[:correct_guesses]
      incorrect_guesses = game_state[:incorrect_guesses]
    else
      game_state = nil
    end
  end

  unless game_state
    words = load_dictionary
    secret_word = pick_random_word(words)
    incorrect_guesses = []
    correct_guesses = []
  end

  max_attempts = 6

  until incorrect_guesses.size >= max_attempts || secret_word.chars.all? { |char| correct_guesses.include?(char) }
    puts display_progress(secret_word, correct_guesses)
    guess = make_guess(incorrect_guesses + correct_guesses)

    if guess == "save"
      save_game({ secret_word: secret_word, correct_guesses: correct_guesses, incorrect_guesses: incorrect_guesses })
      puts "Jogo salvo!"
      break
    end

    if secret_word.include?(guess)
      correct_guesses << guess
    else
      incorrect_guesses << guess
    end

    puts "Erros: #{incorrect_guesses.join(", ")}"
    puts "Tentativas restantes: #{max_attempts - incorrect_guesses.size}"
  end

  if secret_word.chars.all? { |char| correct_guesses.include?(char) }
    puts "Parabéns, você venceu! A palavra era #{secret_word}."
  else
    puts "Você perdeu! A palavra era #{secret_word}."
  end
end

# Iniciar o jogo
play_game
