# Funcionalidade de Exclusão com Opções - Trilhas e Módulos

## Resumo da Implementação

Implementada a funcionalidade de exclusão com confirmação e opções para trilhas e módulos. Agora, ao excluir uma trilha ou módulo, o usuário verá um popup com as seguintes opções:

### Opções de Exclusão

1. **Manter conteúdos** (padrão)
   - Os conteúdos são apenas desvinculados da trilha/módulo
   - Conteúdos compartilhados com outras trilhas permanecem nelas
   - Todos os conteúdos ficam disponíveis na biblioteca

2. **Excluir conteúdos exclusivos**
   - Conteúdos que existem **apenas** nesta trilha/módulo são excluídos permanentemente
   - Conteúdos compartilhados com outras trilhas são mantidos nelas
   - Um aviso visual indica quantos conteúdos estão em outras trilhas

## Arquivos Modificados

### Modelos

**app/models/universidade/trilha.rb**
- Adicionado `conteudos_compartilhados` - retorna conteúdos em mais de uma trilha
- Adicionado `tem_conteudos_compartilhados?` - verifica se há conteúdos compartilhados
- Adicionado `tem_modulos?` - verifica se a trilha tem módulos
- Adicionado `excluir_com_opcoes(excluir_conteudos:)` - método de exclusão com opções

**app/models/universidade/modulo.rb**
- Adicionado `conteudos_compartilhados` - retorna conteúdos em mais de uma trilha
- Adicionado `tem_conteudos_compartilhados?` - verifica se há conteúdos compartilhados
- Adicionado `excluir_com_opcoes(excluir_conteudos:)` - método de exclusão com opções

### Controllers

**app/controllers/universidade/admin/trilhas_controller.rb**
- Atualizado `before_action` para incluir `confirmar_exclusao`
- Criado action `confirmar_exclusao` - mostra o modal de confirmação
- Modificado action `destroy` - implementa exclusão com opções

**app/controllers/universidade/admin/modulos_controller.rb**
- Atualizado `before_action` para incluir `confirmar_exclusao`
- Criado action `confirmar_exclusao` - mostra o modal de confirmação
- Modificado action `destroy` - implementa exclusão com opções

### Rotas

**config/routes.rb**
- Adicionada rota `get :confirmar_exclusao` para trilhas
- Adicionada rota `get :confirmar_exclusao` para módulos

### Views

**app/views/universidade/admin/trilhas/_trilha.html.erb**
- Alterado botão de excluir para abrir modal de confirmação em vez de excluir diretamente

**app/views/universidade/admin/modulos/_modulo_row.html.erb**
- Alterado botão de excluir para abrir modal de confirmação em vez de excluir diretamente

**app/views/universidade/admin/trilhas/confirmar_exclusao.html.erb** (novo)
- Modal de confirmação para exclusão de trilhas
- Mostra informações sobre módulos e conteúdos vinculados
- Destaca conteúdos compartilhados com aviso visual
- Opções de radio button para escolher tipo de exclusão

**app/views/universidade/admin/modulos/confirmar_exclusao.html.erb** (novo)
- Modal de confirmação para exclusão de módulos
- Mostra informações sobre conteúdos vinculados e trilha pai
- Destaca conteúdos compartilhados com aviso visual
- Opções de radio button para escolher tipo de exclusão

## Comportamento

### Ao Excluir uma Trilha

1. Modal mostra:
   - Quantidade de módulos (que serão desvinculados)
   - Quantidade de conteúdos vinculados
   - Destaque se houver conteúdos em outras trilhas

2. Opções:
   - **Manter conteúdos**: Apenas desvincula, mantém tudo na biblioteca
   - **Excluir conteúdos exclusivos**: Remove conteúdos que só existem nesta trilha

3. Efeitos na exclusão:
   - Módulos são desvinculados (trilha_id vira null)
   - trilha_conteudos são removidos (dependent: :destroy)
   - Progressos são removidos (dependent: :destroy)
   - Conteúdos exclusivos são excluídos (se opção selecionada)

### Ao Excluir um Módulo

1. Modal mostra:
   - Quantidade de conteúdos vinculados
   - Trilha a qual o módulo pertence (se houver)
   - Destaque se houver conteúdos em outras trilhas

2. Opções:
   - **Manter conteúdos**: Desvincula do módulo mas mantém na trilha/biblioteca
   - **Excluir conteúdos exclusivos**: Remove conteúdos que só existem na trilha deste módulo

3. Efeitos na exclusão:
   - trilha_conteudos.modulo_id vira null (dependent: :nullify)
   - Conteúdos permanecem vinculados à trilha (se houver uma)
   - Conteúdos exclusivos da trilha são excluídos (se opção selecionada)

## Interface do Usuário

- Modal estilizado com Tailwind CSS
- Visual claro com ícone de alerta
- Informações em destaque sobre o que será afetado
- Avisos visuais (amarelo) para conteúdos compartilhados
- Opções de exclusão com descrições claras
- Botões de ação bem definidos (Cancelar/Excluir)

## Segurança

- Transaction no modelo garante atomicidade
- Verificação de conteúdos compartilhados antes de excluir
- Mensagens claras sobre o que será excluído
- Ação não pode ser desfeita (conforme informado ao usuário)
