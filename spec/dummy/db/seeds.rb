# Seeds para a aplicação Universidade Ink
puts "🌱 Populando banco de dados..."

# Limpar dados existentes
Universidade::Progresso.destroy_all
Universidade::Feedback.destroy_all
Universidade::ConteudoTag.destroy_all
Universidade::Conteudo.destroy_all
Universidade::Modulo.destroy_all
Universidade::Trilha.destroy_all
Universidade::Tag.destroy_all
Universidade::Categoria.destroy_all

puts "✓ Dados limpos"

owner_attrs = { user_id: 1, store_id: 1 }

# ========== TAXONOMIA: CATEGORIAS ==========
puts "\n📁 Criando categorias..."
cat_trafego = Universidade::Categoria.create!(
  nome: "Tráfego Pago",
  descricao: "Conteúdos sobre anúncios, meta ads, google ads e estratégias de mídia paga"
)
cat_gestao = Universidade::Categoria.create!(
  nome: "Gestão de Loja",
  descricao: "Administração, organização e otimização da sua loja virtual"
)
cat_produtos = Universidade::Categoria.create!(
  nome: "Produtos",
  descricao: "Fotografia, descrições, precificação e gestão de catálogo"
)
cat_atendimento = Universidade::Categoria.create!(
  nome: "Atendimento",
  descricao: "Relacionamento com clientes, vendas e pós-venda"
)
puts "✅ #{Universidade::Categoria.count} categorias criadas"

# ========== TAXONOMIA: TAGS ==========
puts "\n🏷️  Criando tags..."
tags_data = %w[
  instagram facebook meta-ads google-ads
  iniciante intermediario avancado
  fotografia video
  conversao funil vendas
  whatsapp email chat
]
tags_data.each { |nome| Universidade::Tag.create!(nome: nome) }
puts "✅ #{Universidade::Tag.count} tags criadas"

# ========== TRILHAS E CONTEÚDOS ==========

# Trilha 1: Tráfego Pago
puts "\n📚 Criando Trilha 1: Tráfego Pago..."
trilha1 = Universidade::Trilha.create!(
  **owner_attrs,
  nome: "Tráfego Pago para E-commerce",
  descricao: "Aprenda a criar campanhas de anúncios para impulsionar suas vendas",
  tags: ["meta-ads", "google-ads"],
  visivel: true,
  rascunho: false,
ordem: 1
)
puts "✅ Trilha criada: #{trilha1.nome}"

# Módulo 1.1
modulo1_1 = Universidade::Modulo.create!(
  **owner_attrs,
  trilha_id: trilha1.id,
  nome: "Introdução ao Instagram Ads",
  descricao: "Conceitos básicos e configuração inicial",
  visivel: true,
  ordem: 1
)
puts "  📦 Módulo: #{modulo1_1.nome}"

# Conteúdo 1.1.1
conteudo1 = Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Como usar Instagram para vender produtos",
  corpo: '{"blocks":[{"type":"titulo","data":{"text":"Instagram: A Vitrine do Seu E-commerce"}},{"type":"texto","data":{"html":"<p>O Instagram é uma das plataformas mais poderosas para vender produtos online. Neste conteúdo, você aprenderá estratégias essenciais para usar Instagram Ads e impulsionar suas vendas.</p>"}},{"type":"titulo","data":{"text":"Por que investir em Meta Ads?"}},{"type":"texto","data":{"html":"<p>As campanhas de Meta Ads (Facebook e Instagram) oferecem:</p><ul><li>Segmentação precisa do público</li><li>Alcance massivo</li><li>Retorno mensurável sobre investimento</li></ul>"}}]}',
  categoria_id: cat_trafego.id,
  visivel: true,
  tempo_estimado_minutos: 8
)
conteudo1.tags << Universidade::Tag.find_by(nome: "instagram")
conteudo1.tags << Universidade::Tag.find_by(nome: "meta-ads")
conteudo1.tags << Universidade::Tag.find_by(nome: "iniciante")

# Associar à trilha via TrilhaConteudo
Universidade::TrilhaConteudo.create!(
  trilha: trilha1,
  conteudo: conteudo1,
  modulo: modulo1_1,
  posicao: 1
)
puts "    📄 Conteúdo: #{conteudo1.titulo}"

# Conteúdo 1.1.2
conteudo2 = Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Configurando sua primeira campanha de anúncios",
  corpo: '{"blocks":[{"type":"titulo","data":{"text":"Passo a passo para criar sua campanha"}},{"type":"texto","data":{"html":"<p>Criar uma campanha de sucesso requer planejamento. Vamos aprender o processo completo.</p>"}},{"type":"destaque","data":{"text":"Dica: Comece com um orçamento pequeno para testar diferentes estratégias."}}]}',
  categoria_id: cat_trafego.id,
  visivel: true,
  tempo_estimado_minutos: 12
)
conteudo2.tags << Universidade::Tag.find_by(nome: "meta-ads")
conteudo2.tags << Universidade::Tag.find_by(nome: "iniciante")

Universidade::TrilhaConteudo.create!(
  trilha: trilha1,
  conteudo: conteudo2,
  modulo: modulo1_1,
  posicao: 2
)
puts "    📄 Conteúdo: #{conteudo2.titulo}"

# Módulo 1.2
modulo1_2 = Universidade::Modulo.create!(
  **owner_attrs,
  trilha_id: trilha1.id,
  nome: "Otimização e Conversão",
  descricao: "Maximize o retorno dos seus anúncios",
  visivel: true,
  ordem: 2
)
puts "  📦 Módulo: #{modulo1_2.nome}"

# Conteúdo 1.2.1
conteudo3 = Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Estratégias de funil de vendas",
  corpo: '{"blocks":[{"type":"titulo","data":{"text":"Entendendo o Funil de Conversão"}},{"type":"texto","data":{"html":"<p>O funil de vendas é essencial para guiar seu público até a compra.</p>"}}]}',
  categoria_id: cat_trafego.id,
  visivel: true,
  tempo_estimado_minutos: 15
)
conteudo3.tags << Universidade::Tag.find_by(nome: "conversao")
conteudo3.tags << Universidade::Tag.find_by(nome: "funil")
conteudo3.tags << Universidade::Tag.find_by(nome: "intermediario")

Universidade::TrilhaConteudo.create!(
  trilha: trilha1,
  conteudo: conteudo3,
  modulo: modulo1_2,
  posicao: 1
)
puts "    📄 Conteúdo: #{conteudo3.titulo}"

# Trilha 2: Gestão de Produtos
puts "\n📚 Criando Trilha 2: Gestão de Produtos..."
trilha2 = Universidade::Trilha.create!(
  **owner_attrs,
  nome: "Gestão de Produtos e Fotografia",
  descricao: "Aprenda a fotografar e apresentar seus produtos para vender mais",
  tags: ["fotografia", "produtos"],
  visivel: true,
  rascunho: false,
  ordem: 2
)
puts "✅ Trilha criada: #{trilha2.nome}"

modulo2_1 = Universidade::Modulo.create!(
  **owner_attrs,
  trilha_id: trilha2.id,
  nome: "Fotografia de Produtos",
  descricao: "Técnicas para fotos profissionais",
  visivel: true,
  ordem: 1
)
puts "  📦 Módulo: #{modulo2_1.nome}"

conteudo4 = Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Fotografia de produtos com celular",
  corpo: '{"blocks":[{"type":"titulo","data":{"text":"Fotos Profissionais com Seu Celular"}},{"type":"texto","data":{"html":"<p>Você não precisa de equipamento caro para criar fotos incríveis de produtos.</p>"}}]}',
  categoria_id: cat_produtos.id,
  visivel: true,
  tempo_estimado_minutos: 10
)
conteudo4.tags << Universidade::Tag.find_by(nome: "fotografia")
conteudo4.tags << Universidade::Tag.find_by(nome: "iniciante")

Universidade::TrilhaConteudo.create!(
  trilha: trilha2,
  conteudo: conteudo4,
  modulo: modulo2_1,
  posicao: 1
)
puts "    📄 Conteúdo: #{conteudo4.titulo}"

# Conteúdo solto (não vinculado a trilha)
puts "\n📄 Criando conteúdos soltos..."
conteudo_solto = Universidade::Conteudo.create!(
  **owner_attrs,
  titulo: "Como melhorar o atendimento via WhatsApp",
  corpo: '{"blocks":[{"type":"titulo","data":{"text":"WhatsApp: Seu Canal de Vendas"}},{"type":"texto","data":{"html":"<p>O WhatsApp é fundamental para o atendimento e vendas em e-commerce brasileiro.</p>"}}]}',
  categoria_id: cat_atendimento.id,
  visivel: true,
  tempo_estimado_minutos: 7
)
conteudo_solto.tags << Universidade::Tag.find_by(nome: "whatsapp")
conteudo_solto.tags << Universidade::Tag.find_by(nome: "iniciante")
conteudo_solto.tags << Universidade::Tag.find_by(nome: "vendas")
puts "✅ Conteúdo solto: #{conteudo_solto.titulo}"

puts "\n" + "="*60
puts "✨ Banco de dados populado com sucesso!"
puts "="*60
puts "📊 Resumo:"
puts "  - #{Universidade::Categoria.count} categorias"
puts "  - #{Universidade::Tag.count} tags"
puts "  - #{Universidade::Trilha.count} trilhas"
puts "  - #{Universidade::Modulo.count} módulos"
puts "  - #{Universidade::Conteudo.count} conteúdos"
puts "  - #{Universidade::TrilhaConteudo.count} vínculos trilha-conteúdo"
puts "="*60
puts "🚀 Acesse /admin para gerenciar categorias, tags e conteúdos!"


