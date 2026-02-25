# Seeds para a aplicação Universidade Ink
puts "🌱 Populando banco de dados..."

# Limpar dados existentes
Universidade::Comentario.destroy_all
Universidade::Progresso.destroy_all
Universidade::Artigo.destroy_all
Universidade::Trilha.destroy_all
Universidade::Modulo.destroy_all
Universidade::Curso.destroy_all

puts "✓ Dados limpos"

# Criar curso
curso = Universidade::Curso.create!(
  nome: "Ruby on Rails - Completo",
  descricao: "Aprenda Ruby on Rails do zero ao avançado com este curso completo",
  tags: ["Ruby", "Rails", "Web Development", "Backend"],
  visivel: true,
  ordem: 1
)

puts "✓ Curso criado: #{curso.nome}"

# Criar módulo 1
modulo1 = Universidade::Modulo.create!(
  curso: curso,
  nome: "Fundamentos do Ruby",
  descricao: "Aprenda os conceitos básicos da linguagem Ruby",
  visivel: true,
  ordem: 1
)

# Criar trilha 1.1
trilha1_1 = Universidade::Trilha.create!(
  modulo: modulo1,
  nome: "Introdução ao Ruby",
  tempo_estimado_minutos: 45,
  visivel: true,
  ordem: 1
)

# Criar artigos da trilha 1.1
Universidade::Artigo.create!(
  trilha: trilha1_1,
  titulo: "O que é Ruby?",
  corpo: {
    "blocks" => [
      {
        "type" => "header",
        "data" => { "text" => "O que é Ruby?", "level" => 1 }
      },
      {
        "type" => "paragraph",
        "data" => { "text" => "Ruby é uma linguagem de programação interpretada, de alto nível e de propósito geral. Foi criada por Yukihiro Matsumoto em 1995 com foco na simplicidade e produtividade." }
      },
      {
        "type" => "header",
        "data" => { "text" => "Características principais", "level" => 2 }
      },
      {
        "type" => "list",
        "data" => {
          "style" => "unordered",
          "items" => [
            "Sintaxe elegante e natural",
            "Orientada a objetos",
            "Tipagem dinâmica",
            "Garbage collection automático",
            "Comunidade ativa e amigável"
          ]
        }
      }
    ]
  },
  tempo_estimado_minutos: 10,
  visivel: true,
  ordem: 1
)

Universidade::Artigo.create!(
  trilha: trilha1_1,
  titulo: "Instalando o Ruby",
  corpo: {
    "blocks" => [
      {
        "type" => "header",
        "data" => { "text" => "Instalando o Ruby", "level" => 1 }
      },
      {
        "type" => "paragraph",
        "data" => { "text" => "Existem várias formas de instalar o Ruby no seu sistema. Vamos ver as principais." }
      },
      {
        "type" => "header",
        "data" => { "text" => "Usando asdf (Recomendado)", "level" => 2 }
      },
      {
        "type" => "code",
        "data" => {
          "code" => "# Instalar asdf\ngit clone https://github.com/asdf-vm/asdf.git ~/.asdf\n\n# Adicionar plugin do Ruby\nasdf plugin add ruby\n\n# Instalar Ruby\nasdf install ruby 3.3.6\nasdf global ruby 3.3.6"
        }
      }
    ]
  },
  tempo_estimado_minutos: 15,
  visivel: true,
  ordem: 2
)

Universidade::Artigo.create!(
  trilha: trilha1_1,
  titulo: "Primeiro programa em Ruby",
  corpo: {
    "blocks" => [
      {
        "type" => "header",
        "data" => { "text" => "Primeiro programa em Ruby", "level" => 1 }
      },
      {
        "type" => "paragraph",
        "data" => { "text" => "Vamos escrever nosso primeiro programa em Ruby - o clássico Hello World!" }
      },
      {
        "type" => "code",
        "data" => {
          "code" => "puts \"Hello, World!\""
        }
      },
      {
        "type" => "paragraph",
        "data" => { "text" => "Execute este código salvando em um arquivo hello.rb e rodando: ruby hello.rb" }
      }
    ]
  },
  tempo_estimado_minutos: 5,
  visivel: true,
  ordem: 3
)

puts "✓ Trilha '#{trilha1_1.nome}' criada com #{trilha1_1.artigos.count} artigos"

# Criar trilha 1.2
trilha1_2 = Universidade::Trilha.create!(
  modulo: modulo1,
  nome: "Variáveis e Tipos de Dados",
  tempo_estimado_minutos: 60,
  visivel: true,
  ordem: 2
)

Universidade::Artigo.create!(
  trilha: trilha1_2,
  titulo: "Declarando Variáveis",
  corpo: {
    "blocks" => [
      {
        "type" => "header",
        "data" => { "text" => "Variáveis em Ruby", "level" => 1 }
      },
      {
        "type" => "paragraph",
        "data" => { "text" => "Ruby possui diferentes tipos de variáveis, cada uma com seu propósito específico." }
      },
      {
        "type" => "code",
        "data" => {
          "code" => "# Variável local\nnome = \"João\"\n\n# Variável de instância\n@idade = 25\n\n# Variável de classe\n@@contador = 0\n\n# Constante\nPI = 3.14159"
        }
      }
    ]
  },
  tempo_estimado_minutos: 20,
  visivel: true,
  ordem: 1
)

Universidade::Artigo.create!(
  trilha: trilha1_2,
  titulo: "Strings e Números",
  corpo: {
    "blocks" => [
      {
        "type" => "header",
        "data" => { "text" => "Trabalhando com Strings e Números", "level" => 1 }
      },
      {
        "type" => "paragraph",
        "data" => { "text" => "Strings e números são os tipos de dados mais básicos e fundamentais." }
      },
      {
        "type" => "code",
        "data" => {
          "code" => "# Strings\nnome = \"Universidade Ink\"\nmensagem = 'Bem-vindo!'\n\n# Números\ninteiro = 42\nflutuante = 3.14\n\n# Operações\nresultado = 10 + 5\nproduto = 3 * 4"
        }
      }
    ]
  },
  tempo_estimado_minutos: 20,
  visivel: true,
  ordem: 2
)

puts "✓ Trilha '#{trilha1_2.nome}' criada com #{trilha1_2.artigos.count} artigos"

# Criar módulo 2
modulo2 = Universidade::Modulo.create!(
  curso: curso,
  nome: "Ruby on Rails Básico",
  descricao: "Introdução ao framework Rails",
  visivel: true,
  ordem: 2
)

# Criar trilha 2.1
trilha2_1 = Universidade::Trilha.create!(
  modulo: modulo2,
  nome: "O que é Rails?",
  tempo_estimado_minutos: 30,
  visivel: true,
  ordem: 1
)

Universidade::Artigo.create!(
  trilha: trilha2_1,
  titulo: "Introdução ao Rails",
  corpo: {
    "blocks" => [
      {
        "type" => "header",
        "data" => { "text" => "Ruby on Rails", "level" => 1 }
      },
      {
        "type" => "paragraph",
        "data" => { "text" => "Rails é um framework web de código aberto escrito em Ruby, seguindo o padrão MVC (Model-View-Controller)." }
      },
      {
        "type" => "header",
        "data" => { "text" => "Por que usar Rails?", "level" => 2 }
      },
      {
        "type" => "list",
        "data" => {
          "style" => "unordered",
          "items" => [
            "Convenção sobre configuração",
            "DRY (Don't Repeat Yourself)",
            "Desenvolvimento rápido",
            "Grande ecossistema de gems",
            "Comunidade ativa"
          ]
        }
      }
    ]
  },
  tempo_estimado_minutos: 15,
  visivel: true,
  ordem: 1
)

Universidade::Artigo.create!(
  trilha: trilha2_1,
  titulo: "Instalando o Rails",
  corpo: {
    "blocks" => [
      {
        "type" => "header",
        "data" => { "text" => "Instalando o Rails", "level" => 1 }
      },
      {
        "type" => "paragraph",
        "data" => { "text" => "Com o Ruby instalado, instalar o Rails é muito simples." }
      },
      {
        "type" => "code",
        "data" => {
          "code" => "# Instalar Rails\ngem install rails\n\n# Verificar versão\nrails -v\n\n# Criar nova aplicação\nrails new meu_app\ncd meu_app\nbin/rails server"
        }
      }
    ]
  },
  tempo_estimado_minutos: 15,
  visivel: true,
  ordem: 2
)

puts "✓ Trilha '#{trilha2_1.nome}' criada com #{trilha2_1.artigos.count} artigos"

puts "\n✅ Seeds concluídas com sucesso!"
puts "📊 Resumo:"
puts "   - #{Universidade::Curso.count} curso(s)"
puts "   - #{Universidade::Modulo.count} módulo(s)"
puts "   - #{Universidade::Trilha.count} trilha(s)"
puts "   - #{Universidade::Artigo.count} artigo(s)"
puts "\n🚀 Acesse http://localhost:3000 para ver a aplicação!"
