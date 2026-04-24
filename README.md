# 🕊️ Manual do Cristão

> Sua jornada espiritual começa aqui. Leia, estude, medite e cresça na fé.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![Android](https://img.shields.io/badge/Android-minSdk%2026-green?logo=android)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📱 Sobre o App

**Manual do Cristão** é um aplicativo completo de Bíblia para Android, desenvolvido em Flutter, com foco em acessibilidade, leitura offline e experiência espiritual rica. Disponível para católicos e evangélicos com suporte a múltiplas versões bíblicas.

---

## ✨ Funcionalidades

### 📖 Bíblia
- **Leitura offline completa** — mais de 31.000 versículos da ACF embarcados no app
- **Múltiplas versões** — ACF, NVI, ARC, NTLH (baixáveis offline individualmente)
- **Planos de leitura** — Bíblia em 1 ano, 6 meses, NT em 3 meses ou leitura livre
- **Leitura em voz alta (TTS)** — ouça os capítulos enquanto faz outras atividades
- **Grifos e anotações** — salve reflexões e destaque versículos favoritos
- **Favoritos** — acesso rápido aos versículos mais queridos

### 🎤 Busca Inteligente
- **Busca por voz** com normalização PT-BR (reconhece "Jo", "João", "Jó" corretamente)
- **Busca por texto** em toda a Bíblia
- **Parser bíblico** — reconhece abreviações, nomes completos e variações faladas

### 🔔 Notificações
- **Versículo do dia** com texto real da API (30 versículos famosos em rotação diária)
- **Plano de leitura** — lembrete para continuar sua leitura
- **Mensagens motivacionais** — palavras de encorajamento
- Reagendamento automático após reinício do celular

### 🎬 Vídeos
- Pregações de Padre Reginaldo Manzotti, Padre Fábio de Melo, Pastor Cláudio Duarte e outros
- Integração com YouTube

### 👤 Perfil
- Foto de perfil (câmera ou galeria)
- Estatísticas de leitura (streak, livros lidos, notas)
- Configurações personalizadas por religião

### ⚙️ Configurações
- Tema claro/escuro
- Tamanho de fonte ajustável
- Versão e religião configuráveis
- Gerenciamento de versões offline
- Atualização de texto bíblico

### ♿ Acessibilidade
- Fonte ajustável (14–28px)
- Onboarding com scroll — funciona em qualquer tamanho de fonte
- Busca por voz integrada

---

## 🏗️ Tecnologias

| Tecnologia | Uso |
|---|---|
| **Flutter 3.x** | Framework principal |
| **Dart 3.x** | Linguagem |
| **Provider** | Gerenciamento de estado |
| **SQLite (sqflite)** | Cache offline de versículos |
| **Shared Preferences** | Configurações persistentes |
| **awesome_notifications** | Notificações agendadas |
| **speech_to_text** | Reconhecimento de voz |
| **image_picker** | Foto de perfil |
| **flutter_tts** | Leitura em voz alta |
| **http** | Requisições às APIs |
| **url_launcher** | Abertura de links externos |

---

## 🌐 APIs Utilizadas

| Prioridade | API | Descrição |
|---|---|---|
| 0️⃣ | `assets/bible/acf.json` | Bíblia completa embarcada (offline) |
| 1️⃣ | `bible-api.com` | Tradução Almeida PT-BR (principal online) |
| 2️⃣ | `bolls.life` | Fallback online |
| 3️⃣ | `abibliadigital.com.br` | Quando disponível |
| 4️⃣ | Versículos embarcados | Fallback offline parcial |

---

## 📦 Estrutura do Projeto

```
lib/
├── main.dart                    # Entrada do app
├── models/
│   └── bible_models.dart        # Modelos de dados
├── providers/
│   └── app_provider.dart        # Estado global
├── screens/
│   ├── home_screen.dart         # Tela inicial
│   ├── books_screen.dart        # Lista de livros
│   ├── chapters_screen.dart     # Capítulos
│   ├── chapter_reader_screen.dart # Leitura
│   ├── search_screen.dart       # Busca + voz
│   ├── notes_screen.dart        # Anotações
│   ├── read_screen.dart         # Planos + vídeos
│   ├── profile_screen.dart      # Perfil
│   ├── settings_screen.dart     # Configurações
│   ├── download_screen.dart     # Versões offline
│   ├── ai_screen.dart           # Assistente IA (em desenvolvimento)
│   └── onboarding_screen.dart   # Primeiro uso
├── services/
│   ├── bible_service.dart       # Acesso às APIs bíblicas
│   ├── notification_service.dart # Notificações
│   ├── offline_service.dart     # Cache SQLite
│   ├── reading_plan_service.dart # Planos de leitura
│   └── tts_service.dart         # Leitura em voz alta
├── theme/
│   └── app_theme.dart           # Tema do app
├── utils/
│   └── bible_reference_parser.dart # Parser de referências bíblicas
└── widgets/
    └── progress_ring.dart       # Widget de progresso

assets/
├── bible/
│   └── acf.json                 # Bíblia completa offline (~4MB)
└── icon/
    └── app_icon.png             # Ícone do app
```

---

## 🚀 Como Rodar

### Pré-requisitos
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code
- Java 21
- Android SDK (minSdk 26)

### Instalação

```bash
# Clone o repositório
git clone https://github.com/Rafaelpontara/manual-do-cristao.git

# Entre na pasta
cd manual-do-cristao

# Instale as dependências
flutter pub get

# Rode o app
flutter run
```

### Build de Produção

```bash
# APK
flutter build apk --release

# AAB (Play Store)
flutter build appbundle --release
```

---

## 📋 Configuração do Ambiente

### `pubspec.yaml` — Dependências principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.x
  shared_preferences: ^2.x
  sqflite: ^2.x
  http: ^1.x
  awesome_notifications: ^0.10.1
  speech_to_text: ^7.0.0
  image_picker: ^1.0.7
  flutter_tts: ^4.x
  url_launcher: ^6.x
  connectivity_plus: ^7.x
```

### Assets

```yaml
flutter:
  assets:
    - assets/bible/acf.json
```

---

## 📥 Download da Bíblia Offline

O `acf.json` já está incluído no repositório. Para regenerar ou baixar versões adicionais:

```bash
# Baixa a Bíblia completa via bible-api.com (~45 min)
python download_bible.py
```

---

## 🗺️ Roadmap

- [x] Bíblia offline completa (ACF)
- [x] Busca por voz com normalização PT-BR
- [x] Notificações com versículo real da API
- [x] Planos de leitura
- [x] Foto de perfil
- [x] Versões adicionais offline
- [ ] Assistente IA "Luz" (em desenvolvimento)
- [ ] Sincronização na nuvem
- [ ] Widget na tela inicial do Android
- [ ] Compartilhamento de versículos
- [ ] Plano de leitura personalizado

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🙏 Créditos

- Textos bíblicos: [bible-api.com](https://bible-api.com) — Tradução Almeida (Domínio Público)
- Notificações: [awesome_notifications](https://pub.dev/packages/awesome_notifications)
- Ícones: Material Design Icons

---

<div align="center">
  <strong>🕊️ Manual do Cristão — Feito com fé e amor</strong>
</div>
