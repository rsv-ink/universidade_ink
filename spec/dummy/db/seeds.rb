# Seeds para a aplicação Universidade Ink
puts "🌱 Populando banco de dados..."

# Limpar dados existentes
Universidade::Progresso.destroy_all
Universidade::Feedback.destroy_all
Universidade::Conteudo.destroy_all
Universidade::Modulo.destroy_all
Universidade::Trilha.destroy_all

puts "✓ Dados limpos"

owner_attrs = { user_id: 1, store_id: 1 }

# Trilha 1: Ruby on Rails
trilha1 = Universidade::Trilha.create!(
  **owner_attrs,
  nome: "Ruby on Rails Essencial",
  descricao: "Aprenda os fundamentos do framework Ruby on Rails",
  tags: ["ruby", "rails", "backend"],
  visivel: true,
  rascunho: false,
  ordem: 1
)
puts "✅ Trilha criada: #{trilha1.nome}"

# Módulo 1.1
modulo1_1 = Universidade::Modulo.create!(
  **owner_attrs,
  trilha_id: trilha1.id,
  nome: "Introdução ao Rails",
  descricao: "Conceitos básicos e instalação",
  visivel: true,
  ordem: 1
)
puts "  📦 Módulo: #{modulo1_1.nome}"

# Conteúdos do módulo 1.1
Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "O que é Ruby on Rails?",
  corpo: "<h2>Introdução</h2><p>Ruby on Rails é um framework web de código aberto escrito em Ruby, seguindo o padrão MVC (Model-View-Controller).</p><h3>Por que usar Rails?</h3><ul><li>Convenção sobre configuração</li><li>DRY (Don't Repeat Yourself)</li><li>Desenvolvimento rápido</li><li>Grande ecossistema de gems</li></ul>",
  modulo_id: modulo1_1.id,
  visivel: true,
  ordem: 1
)

Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Instalando o Rails",
  corpo: "<h2>Passo a passo</h2><p>Para instalar o Rails, você precisa ter o Ruby instalado. Depois, basta executar:</p><pre><code>gem install rails\nrails -v\nrails new meu_app\ncd meu_app\nbin/rails server</code></pre>",
  modulo_id: modulo1_1.id,
  visivel: true,
  ordem: 2
)
puts "    📄 2 conteúdos criados"

# Módulo 1.2
modulo1_2 = Universidade::Modulo.create!(
  **owner_attrs,
  trilha_id: trilha1.id,
  nome: "Models e Banco de Dados",
  descricao: "Active Record e migrations",
  visivel: true,
  ordem: 2
)
puts "  📦 Módulo: #{modulo1_2.nome}"

Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Active Record Básico",
  corpo: "<h2>Models</h2><p>O Active Record é a camada ORM do Rails. Ele conecta objetos Ruby a tabelas do banco de dados.</p><pre><code>class User < ApplicationRecord\n  has_many :posts\n  validates :email, presence: true\nend</code></pre>",
  modulo_id: modulo1_2.id,
  visivel: true,
  ordem: 1
)

Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Migrations",
  corpo: "<h2>Gerenciando o Schema</h2><p>Migrations permitem versionar e modificar o schema do banco de dados de forma controlada.</p><pre><code>rails generate migration CreateUsers\nrails db:migrate</code></pre>",
  modulo_id: modulo1_2.id,
  visivel: true,
  ordem: 2
)
puts "    📄 2 conteúdos criados"

# Trilha 2: JavaScript Moderno
trilha2 = Universidade::Trilha.create!(
  **owner_attrs,
  nome: "JavaScript Moderno",
  descricao: "ES6+, async/await e muito mais",
  tags: ["javascript", "frontend", "es6"],
  visivel: true,
  rascunho: false,
  ordem: 2
)
puts "✅ Trilha criada: #{trilha2.nome}"

modulo2_1 = Universidade::Modulo.create!(
  **owner_attrs,
  trilha_id: trilha2.id,
  nome: "ES6 Fundamentals",
  descricao: "Arrow functions, destructuring, etc",
  visivel: true,
  ordem: 1
)
puts "  📦 Módulo: #{modulo2_1.nome}"

Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Arrow Functions",
  corpo: "<h2>Sintaxe moderna</h2><p>Arrow functions simplificam a escrita de funções em JavaScript.</p><pre><code>// Função tradicional\nfunction soma(a, b) { return a + b; }\n\n// Arrow function\nconst soma = (a, b) => a + b;</code></pre>",
  modulo_id: modulo2_1.id,
  visivel: true,
  ordem: 1
)

Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Destructuring",
  corpo: "<h2>Extraindo valores</h2><p>Destructuring permite extrair valores de arrays e objetos de forma concisa.</p><pre><code>const pessoa = { nome: 'João', idade: 25 };\nconst { nome, idade } = pessoa;\n\nconst numeros = [1, 2, 3];\nconst [primeiro, segundo] = numeros;</code></pre>",
  modulo_id: modulo2_1.id,
  visivel: true,
  ordem: 2
)

Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Promises e Async/Await",
  corpo: "<h2>Programação assíncrona</h2><p>Promises e async/await facilitam o trabalho com código assíncrono.</p><pre><code>// Usando Promises\nfetch('/api/data')\n  .then(res => res.json())\n  .then(data => console.log(data));\n\n// Usando async/await\nasync function fetchData() {\n  const res = await fetch('/api/data');\n  const data = await res.json();\n  console.log(data);\n}</code></pre>",
  modulo_id: modulo2_1.id,
  visivel: true,
  ordem: 3
)
puts "    📄 3 conteúdos criados"

# Trilha 3: Stimulus JS
trilha3 = Universidade::Trilha.create!(
  **owner_attrs,
  nome: "Stimulus JS",
  descricao: "Framework JavaScript modesto para HTML",
  tags: ["stimulus", "javascript", "hotwire"],
  visivel: true,
  rascunho: false,
  ordem: 3
)
puts "✅ Trilha criada: #{trilha3.nome}"

modulo3_1 = Universidade::Modulo.create!(
  **owner_attrs,
  trilha_id: trilha3.id,
  nome: "Controllers",
  descricao: "Criando controllers Stimulus",
  visivel: true,
  ordem: 1
)
puts "  📦 Módulo: #{modulo3_1.nome}"

Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Primeiro Controller",
  corpo: "<h2>Hello Stimulus</h2><p>Vamos criar nosso primeiro controller Stimulus.</p><pre><code>// hello_controller.js\nimport { Controller } from '@hotwired/stimulus'\n\nexport default class extends Controller {\n  connect() {\n    console.log('Hello, Stimulus!')\n  }\n}</code></pre><pre><code>&lt;div data-controller=\"hello\"&gt;\n  &lt;h1&gt;Stimulus está funcionando!&lt;/h1&gt;\n&lt;/div&gt;</code></pre>",
  modulo_id: modulo3_1.id,
  visivel: true,
  ordem: 1
)

Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Targets e Actions",
  corpo: "<h2>Conectando HTML</h2><p>Targets são referências a elementos HTML, e actions são eventos que disparam métodos do controller.</p><pre><code>export default class extends Controller {\n  static targets = ['name', 'output']\n\n  greet() {\n    this.outputTarget.textContent = `Olá, ${this.nameTarget.value}!`\n  }\n}</code></pre><pre><code>&lt;div data-controller=\"greeter\"&gt;\n  &lt;input data-greeter-target=\"name\" type=\"text\"&gt;\n  &lt;button data-action=\"click->greeter#greet\"&gt;Cumprimentar&lt;/button&gt;\n  &lt;p data-greeter-target=\"output\"&gt;&lt;/p&gt;\n&lt;/div&gt;</code></pre>",
  modulo_id: modulo3_1.id,
  visivel: true,
  ordem: 2
)
puts "    📄 2 conteúdos criados"

# Conteúdo solto (direto na trilha, sem módulo)
Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Recursos Adicionais",
  corpo: "<h2>Links úteis</h2><ul><li><a href='https://stimulus.hotwired.dev'>Documentação oficial do Stimulus</a></li><li><a href='https://hotwired.dev'>Hotwire</a></li><li><a href='https://turbo.hotwired.dev'>Turbo</a></li></ul>",
  trilha_id: trilha3.id,
  modulo_id: nil,
  visivel: true,
  ordem: 10
)
puts "  📄 1 conteúdo solto criado"

puts ""
puts "✨ Dados criados com sucesso!"
puts "📊 Total: #{Universidade::Trilha.count} trilhas, #{Universidade::Modulo.count} módulos, #{Universidade::Conteudo.count} conteúdos"
puts "🚀 Acesse http://localhost:3000/admin para gerenciar o conteúdo!"

