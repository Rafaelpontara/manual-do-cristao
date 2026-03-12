# 📖 Palavra Viva — Aplicativo Bíblico Flutter

## 🕊️ Visão Geral

**Palavra Viva** é um aplicativo bíblico completo desenvolvido em Flutter/Dart, com design sofisticado inspirado em manuscritos iluminados medievais — paleta dourada e azul-marinho profundo. Ideal para leitores de todas as idades, com acessibilidade especial para idosos.

---

## ✨ Funcionalidades Implementadas

### 📚 Leitura Bíblica
- **66 livros** completos (Antigo e Novo Testamento)
- **Filtro proeminente** por Antigo/Novo Testamento com chips visuais
- Seleção de capítulos com grade visual de progresso
- **Versículos interativos** — toque para selecionar, pressão longa para opções

### 🎨 Marcação e Grifos
- **4 cores de grifo**: amarelo, verde, azul, rosa
- Marcação de versículos favoritos (bookmarks)
- Lista de todos os grifos e favoritos na tela inicial

### 📝 Bloco de Anotações
- Criação e edição de notas com título, conteúdo e referência bíblica
- **5 cores de destaque** para organização visual
- Busca em tempo real por título ou conteúdo
- Confirmação antes de excluir

### 📅 Planos de Leitura Personalizados
- **Bíblia em 1 Ano** (365 dias, 3-4 cap/dia)
- **Bíblia em 6 Meses** (180 dias, 6-8 cap/dia)
- **Novo Testamento em 3 Meses** (90 dias)
- Progresso diário com marcação de conclusão
- Barra de progresso em tempo real

### 📊 Progresso de Leitura
- **Porcentagem por livro** visível diretamente na lista
- Barra de progresso por capítulo
- Estatísticas gerais (livros concluídos, % total, dias seguidos)
- 🔥 **Sequência de dias** (streak) de leitura

### 🔀 Versículo Aleatório
- Acesso rápido na Home com botão dedicado
- Compartilhamento direto com um clique

### 📤 Compartilhamento
- **Compartilhar** versículos via redes sociais / WhatsApp / mensagens
- **Copiar** com formatação profissional: `"texto" — Livro cap:versículo`
- Disponível em todo versículo e no card do dia

### ⛪ Seleção de Religião e Versão
- **Católica** — inclui deuterocanônicos; versões: ACF, NTLH, NVI-PT
- **Evangélica/Protestante** — 66 livros; versões: ACF, ARC, NTLH, NVI-PT
- **Ortodoxa** — versões: ACF, NTLH
- Onboarding completo na primeira abertura

### 📱 Versões da Bíblia
- ACF — Almeida Corrigida Fiel
- ARC — Almeida Revista e Corrigida
- NTLH — Nova Tradução na Linguagem de Hoje
- NVI-PT — Nova Versão Internacional (Português)

### 🌙 Tema Claro / Escuro
- Toggle rápido no header da Home
- Persistido entre sessões com SharedPreferences

### 🎥 Vídeos Explicativos (YouTube)
- Listagem de padres e pastores brasileiros relevantes
- Padre Reginaldo Manzotti, Padre Fábio de Melo
- Pastor Cláudio Duarte, Lucinho Barreto
- Integrado por livro bíblico
- Aba "Vídeos" na tela de Leitura

### 🔔 Notificações Diárias
- Interface para configurar lembretes
- Suporte a `flutter_local_notifications`
- Permissões do Android configuradas

### 🎤 Busca por Voz (Acessibilidade para Idosos)
- Interface intuitiva com botão grande de microfone
- Instruções claras para falar o nome de livros/versículos
- Integrado com `speech_to_text`

### ♿ Modo Acessível
- Controle de tamanho de fonte (14px–28px)
- Botão "Maximizar Fonte" para idosos
- Interface simplificada e clara

---

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point
├── theme/
│   └── app_theme.dart           # Temas claro e escuro (Playfair + Lato)
├── models/
│   └── bible_models.dart        # BibleBook, Note, ReadingPlan, VideoLesson...
├── providers/
│   └── app_provider.dart        # Estado global com ChangeNotifier
├── services/
│   └── bible_service.dart       # API e dados bíblicos
├── screens/
│   ├── onboarding_screen.dart   # Seleção de religião e versão
│   ├── main_navigation.dart     # Bottom nav bar
│   ├── home_screen.dart         # Dashboard principal
│   ├── books_screen.dart        # Lista de livros com filtro AT/NT
│   ├── chapters_screen.dart     # Grade de capítulos com progresso
│   ├── chapter_reader_screen.dart # Leitor com grifos e ações
│   ├── read_screen.dart         # Plano de leitura + cronológico + vídeos
│   ├── notes_screen.dart        # Bloco de anotações
│   └── profile_screen.dart      # Configurações e estatísticas
└── widgets/
    └── progress_ring.dart       # Widget de anel de progresso
```

---

## 🚀 Como Rodar

### Pré-requisitos
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android Studio ou VS Code com extensão Flutter

### Instalação

```bash
cd biblia_app
flutter pub get
flutter run
```

### Para Android
```bash
flutter build apk --release
```

### Para iOS
```bash
flutter build ipa --release
```

---

## 📦 Principais Dependências

| Pacote | Uso |
|--------|-----|
| `provider` | Gerenciamento de estado |
| `shared_preferences` | Persistência de dados |
| `google_fonts` | Fontes Playfair Display + Lato |
| `share_plus` | Compartilhamento nativo |
| `speech_to_text` | Busca por voz |
| `flutter_local_notifications` | Notificações locais |
| `youtube_player_flutter` | Player de vídeos YouTube |
| `sqflite` | Banco de dados local |
| `uuid` | IDs únicos para notas |
| `table_calendar` | Calendário de progresso |

---

## 🎨 Design System

### Paleta de Cores
| Cor | Hex | Uso |
|-----|-----|-----|
| Gold Primary | `#D4A853` | Destaques, CTAs, progresso |
| Navy Deep | `#0D1B2A` | Background escuro |
| Cream White | `#F8F3E8` | Texto principal claro |
| Forest Green | `#2D6A4F` | Concluído, sucesso |
| Crimson | `#B5451B` | Alertas, streak |

### Tipografia
- **Display / Títulos**: Playfair Display (elegante, sacro)
- **Corpo / UI**: Lato (legível, moderno)

---

## 🔮 Próximas Funcionalidades

- [ ] Integração real com API ABíblia.digital
- [ ] Audio player para ouvir a Bíblia
- [ ] Estudo por temas (Amor, Perdão, Fé...)
- [ ] Grupos de estudo / compartilhamento social
- [ ] Backup em nuvem (Firebase)
- [ ] Modo offline completo com conteúdo baixado
- [ ] Comentários de estudiosos por versículo

---

## 📄 Licença

MIT License — Feito com fé e amor 🕊️
