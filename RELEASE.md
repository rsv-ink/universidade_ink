# Guia de Versionamento e Release

Este documento descreve o processo de versionamento e release da gem Universidade.

## Versionamento Semântico

Seguimos o [Semantic Versioning 2.0.0](https://semver.org/lang/pt-BR/):

- **MAJOR** (X.0.0): Mudanças incompatíveis na API
- **MINOR** (0.X.0): Novas funcionalidades mantendo compatibilidade
- **PATCH** (0.0.X): Correções de bugs mantendo compatibilidade

### Exemplos

- `0.1.0 → 0.1.1`: Correção de bug
- `0.1.0 → 0.2.0`: Nova funcionalidade
- `0.1.0 → 1.0.0`: Mudança que quebra compatibilidade

## Comandos Disponíveis

### Ver versão atual
```bash
bundle exec rake universidade:version:show
```

### Informações da gem
```bash
bundle exec rake universidade:info
```

### Validar estrutura
```bash
bundle exec rake universidade:validate
```

### Incrementar versão

**Patch** (correção de bug):
```bash
bundle exec rake universidade:version:patch
```

**Minor** (nova funcionalidade):
```bash
bundle exec rake universidade:version:minor
```

**Major** (breaking change):
```bash
bundle exec rake universidade:version:major
```

## Processo de Release

### 1. Preparar o Release

```bash
# Certifique-se que está na branch main e atualizada
git checkout main
git pull origin main

# Certifique-se que todos os testes passam
bundle exec rspec

# Valide a estrutura da gem
bundle exec rake universidade:validate
```

### 2. Atualizar CHANGELOG.md

Edite `CHANGELOG.md` e:
- Mova as mudanças de `[Unreleased]` para a nova versão
- Adicione a data no formato `## [X.Y.Z] - YYYY-MM-DD`
- Atualize os links no final do arquivo

Exemplo:
```markdown
## [Unreleased]

## [0.2.0] - 2026-03-15

### Added
- Nova funcionalidade XYZ

### Fixed
- Correção do bug ABC
```

### 3. Incrementar Versão

```bash
# Para correção de bug
bundle exec rake universidade:version:patch

# Para nova funcionalidade
bundle exec rake universidade:version:minor

# Para breaking change
bundle exec rake universidade:version:major
```

### 4. Commit e Tag

```bash
# Verificar mudanças
git diff

# Adicionar arquivos modificados
git add lib/universidade/version.rb CHANGELOG.md

# Commit
git commit -m "Bump version to X.Y.Z"

# Criar tag
git tag -a vX.Y.Z -m "Release version X.Y.Z"

# Push do commit e da tag
git push origin main
git push origin vX.Y.Z
```

### 5. Build da Gem

```bash
# Limpar gems antigas
rm -f *.gem

# Build
gem build universidade.gemspec

# Verificar o arquivo gerado
ls -lh universidade-*.gem
```

### 6. Publicar (Opcional)

**GitHub Packages:**
```bash
# Configurar autenticação
export GITHUB_TOKEN=seu_token

# Publicar
gem push --key github \
  --host https://rubygems.pkg.github.com/ink \
  universidade-X.Y.Z.gem
```

**RubyGems (se aplicável):**
```bash
gem push universidade-X.Y.Z.gem
```

## Checklist de Release

- [ ] Todos os testes passando
- [ ] CHANGELOG.md atualizado
- [ ] Versão incrementada corretamente
- [ ] Commit com mensagem clara
- [ ] Tag criada
- [ ] Push realizado (commit + tag)
- [ ] Gem buildada
- [ ] Gem publicada (se aplicável)
- [ ] Release notes criadas no GitHub

## Instalação no Projeto Host

### Via Git (Desenvolvimento)

```ruby
# Gemfile
gem 'universidade', git: 'https://github.com/ink/universidade', tag: 'v0.1.0'
```

### Via GitHub Packages

```ruby
# Gemfile
source 'https://rubygems.pkg.github.com/ink' do
  gem 'universidade', '~> 0.1.0'
end
```

### Via Path Local

```ruby
# Gemfile
gem 'universidade', path: '../universidade_ink'
```

## Convenções de Commit

Seguimos o padrão de commits semânticos:

- `feat:` Nova funcionalidade (bump MINOR)
- `fix:` Correção de bug (bump PATCH)
- `docs:` Apenas documentação
- `style:` Formatação de código
- `refactor:` Refatoração sem mudança de comportamento
- `test:` Adição ou correção de testes
- `chore:` Tarefas de manutenção
- `BREAKING CHANGE:` Mudança incompatível (bump MAJOR)

### Exemplos

```bash
git commit -m "feat: adiciona sistema de notificações"
git commit -m "fix: corrige cálculo de percentual de progresso"
git commit -m "docs: atualiza README com instruções de instalação"
git commit -m "refactor: reorganiza controllers"
git commit -m "BREAKING CHANGE: remove suporte a Rails 6"
```

## Troubleshooting

### Erro ao fazer push da tag

```bash
# Verificar se a tag já existe
git tag -l

# Deletar tag local se necessário
git tag -d vX.Y.Z

# Deletar tag remota se necessário
git push origin :refs/tags/vX.Y.Z
```

### Reverter uma versão

```bash
# Reverter commit
git revert HEAD

# Deletar tag
git tag -d vX.Y.Z
git push origin :refs/tags/vX.Y.Z
```

### Verificar dependências

```bash
bundle outdated
bundle update
```

## Recursos

- [Semantic Versioning](https://semver.org/lang/pt-BR/)
- [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/)
- [Conventional Commits](https://www.conventionalcommits.org/pt-br/)
- [GitHub Packages](https://docs.github.com/en/packages)
