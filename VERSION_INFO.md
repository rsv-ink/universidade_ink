# Informações de Versionamento

## Versão Atual

**v0.1.0** - 4 de março de 2026

## Estrutura de Versionamento

```
lib/universidade/version.rb   → Arquivo principal de versão
CHANGELOG.md                   → Histórico de mudanças
RELEASE.md                     → Guia de release
```

## Comandos Rápidos

### Mostrar versão
```bash
bin/universidade version
# ou
cd spec/dummy && bundle exec rake universidade:version:show
```

### Informações da gem
```bash
bin/universidade info
# ou
cd spec/dummy && bundle exec rake universidade:info
```

### Validar estrutura
```bash
bin/build validate
# ou
cd spec/dummy && bundle exec rake universidade:validate
```

### Build da gem
```bash
bin/build build
```

### Incrementar versão

```bash
# PATCH (0.1.0 → 0.1.1) - Correção de bug
cd spec/dummy && bundle exec rake universidade:version:patch

# MINOR (0.1.0 → 0.2.0) - Nova funcionalidade
cd spec/dummy && bundle exec rake universidade:version:minor

# MAJOR (0.1.0 → 1.0.0) - Breaking change
cd spec/dummy && bundle exec rake universidade:version:major
```

## Convenções

### Semantic Versioning

- **MAJOR**: Mudanças incompatíveis na API
- **MINOR**: Novas funcionalidades compatíveis
- **PATCH**: Correções de bugs

### Commits

- `feat:` → Nova funcionalidade (MINOR)
- `fix:` → Correção de bug (PATCH)
- `BREAKING CHANGE:` → Mudança incompatível (MAJOR)

## Workflow de Release

1. **Atualizar CHANGELOG.md**
2. **Incrementar versão** (`rake universidade:version:patch|minor|major`)
3. **Validar** (`bin/build validate`)
4. **Commit** (`git commit -m "Bump version to X.Y.Z"`)
5. **Tag** (`git tag -a vX.Y.Z -m "Release X.Y.Z"`)
6. **Push** (`git push && git push --tags`)
7. **Build** (`bin/build build`)

## Scripts Disponíveis

| Script            | Descrição                      |
|-------------------|--------------------------------|
| `bin/universidade`| CLI principal da gem           |
| `bin/build`       | Build e gestão de releases     |

## Arquivos de Documentação

| Arquivo           | Conteúdo                       |
|-------------------|--------------------------------|
| `CHANGELOG.md`    | Histórico de mudanças          |
| `RELEASE.md`      | Guia completo de release       |
| `VERSION_INFO.md` | Este arquivo                   |
| `README.md`       | Documentação principal         |

## Histórico de Versões

### 0.1.0 (2026-03-04)
- Versão inicial com versionamento completo
- Sistema de taxonomia
- Nova hierarquia de conteúdo
- Sistema de seções
- Multi-tenancy
