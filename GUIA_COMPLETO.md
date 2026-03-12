# 🚀 Guia Completo — Palavra Viva no VS Code

---

## PASSO 1 — Instalar o Flutter SDK

### Windows
1. Acesse: https://docs.flutter.dev/get-started/install/windows
2. Clique em **"Download Flutter SDK"**
3. Extraia o zip em `C:\flutter` (NUNCA em `C:\Program Files`)
4. Adicione ao PATH:
   - Pesquise "variáveis de ambiente" no Windows
   - Em "Variáveis do Sistema" → Path → Novo → `C:\flutter\bin`
5. Reinicie o PC

### macOS
```bash
brew install flutter
```
Ou baixe em: https://docs.flutter.dev/get-started/install/macos

### Linux (Ubuntu/Debian)
```bash
sudo snap install flutter --classic
```

---

## PASSO 2 — Instalar o VS Code e Extensões

1. Baixe o VS Code: https://code.visualstudio.com
2. Abra o VS Code
3. Vá em **Extensões** (Ctrl+Shift+X)
4. Instale estas extensões:
   - **Flutter** (da Dart Code) ← obrigatória
   - **Dart** (da Dart Code) ← obrigatória
   - **Flutter Widget Snippets** ← recomendada

---

## PASSO 3 — Instalar o Android Studio (para emulador)

1. Baixe: https://developer.android.com/studio
2. Durante a instalação, marque **"Android Virtual Device"**
3. Após instalar, abra o Android Studio
4. Vá em **More Actions → SDK Manager**
5. Instale o **Android SDK** (versão 33 ou superior)
6. Vá em **More Actions → Virtual Device Manager**
7. Clique em **"Create Device"** → Pixel 7 → Android 13 → Finish

---

## PASSO 4 — Configurar o Java (necessário para Android)

### Windows
1. Baixe o JDK 17: https://adoptium.net/temurin/releases/?version=17
2. Instale e adicione ao PATH:
   - `JAVA_HOME` = `C:\Program Files\Eclipse Adoptium\jdk-17...`

### macOS/Linux
```bash
brew install openjdk@17
# ou
sudo apt install openjdk-17-jdk
```

---

## PASSO 5 — Verificar a instalação

Abra o terminal e rode:
```bash
flutter doctor
```

Você deve ver algo assim:
```
[✓] Flutter (Channel stable)
[✓] Android toolchain
[✓] VS Code (version 1.xx)
[✓] Android Studio
[✓] Connected device
```

Se aparecer [✗] em algum item, siga as instruções que o próprio flutter doctor sugere.

---

## PASSO 6 — Extrair e Abrir o Projeto

1. Extraia o arquivo `biblia_app_flutter.zip`
2. Abra o VS Code
3. Vá em **File → Open Folder**
4. Selecione a pasta `biblia_app`
5. O VS Code vai detectar automaticamente que é um projeto Flutter

---

## PASSO 7 — Corrigir as Dependências (IMPORTANTE)

O projeto original usa muitas dependências. Vamos usar apenas as que são necessárias para funcionar:

### 7.1 — Substitua o pubspec.yaml

Abra o arquivo `pubspec.yaml` e **substitua TODO o conteúdo** por:

```yaml
name: palavra_viva
description: Palavra Viva - Aplicativo Bíblico
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  google_fonts: ^6.2.1
  share_plus: ^7.2.2
  uuid: ^4.3.3
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### 7.2 — Instalar as dependências

No terminal do VS Code (Ctrl+`):
```bash
flutter pub get
```

---

## PASSO 8 — Corrigir os imports do projeto

Como removemos algumas dependências, precisamos ajustar os arquivos.

### 8.1 — Remover import de share_plus do home_screen.dart

Abra `lib/screens/home_screen.dart` e remova ou comente a linha:
```dart
// import 'package:share_plus/share_plus.dart';
```

E substitua todas as chamadas `Share.share(...)` por:
```dart
// Share.share(...) → comentar por enquanto
```

### 8.2 — Corrigir main.dart

Abra `lib/main.dart` e certifique que está assim:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
```

---

## PASSO 9 — Rodar o App

### 9.1 — Iniciar o Emulador
1. Abra o Android Studio
2. Clique em **Virtual Device Manager** (ícone de celular na barra lateral)
3. Clique no ▶️ play ao lado do Pixel 7
4. Aguarde o emulador abrir (pode demorar 2-3 minutos na primeira vez)

### 9.2 — Rodar no VS Code
1. No VS Code, veja no canto inferior direito se aparece o nome do emulador
2. Se não aparecer, pressione **Ctrl+Shift+P** → "Flutter: Select Device"
3. Escolha o emulador Android
4. Pressione **F5** ou vá em **Run → Start Debugging**
5. Aguarde o build (primeira vez pode demorar 3-5 minutos)

### Ou pelo terminal:
```bash
flutter run
```

---

## PASSO 10 — Rodar no seu celular Android (Alternativa mais fácil!)

1. No seu celular Android, vá em **Configurações → Sobre o Telefone**
2. Toque **7 vezes** em "Número da Versão" para ativar o Modo Desenvolvedor
3. Vá em **Configurações → Opções do Desenvolvedor**
4. Ative **"Depuração USB"**
5. Conecte o celular ao PC com cabo USB
6. Aceite a permissão de depuração no celular
7. No VS Code, selecione seu celular na barra inferior
8. Pressione F5 para rodar

---

## ❌ Erros Comuns e Soluções

### "flutter: command not found"
→ Adicione o Flutter ao PATH (veja Passo 1)

### "Android license status unknown"
```bash
flutter doctor --android-licenses
# Pressione 'y' para aceitar todas as licenças
```

### "Gradle build failed"
Abra `android/build.gradle` e verifique a versão do Kotlin:
```gradle
ext.kotlin_version = '1.9.0'
```

### "No devices found"
→ Verifique se o emulador está rodando OU se a depuração USB está ativa no celular

### Erros de import (pacote não encontrado)
```bash
flutter clean
flutter pub get
flutter run
```

### "Null check operator used on a null value"
→ Rode `flutter clean` e depois `flutter run` novamente

---

## 🔧 Versão Simplificada para Funcionar Rápido

Se tiver muitos erros, crie um projeto novo limpo:

```bash
# 1. Crie projeto novo
flutter create palavra_viva_app
cd palavra_viva_app

# 2. Copie apenas os arquivos lib/ do projeto
# (substitua a pasta lib/ pela do zip)

# 3. Atualize o pubspec.yaml (versão simplificada acima)

# 4. Instale dependências
flutter pub get

# 5. Rode
flutter run
```

---

## 📱 Gerar APK para instalar no celular

```bash
flutter build apk --release
```

O APK estará em:
`build/app/outputs/flutter-apk/app-release.apk`

Transfira para o celular e instale!

---

## 🆘 Precisa de Ajuda?

- Documentação oficial: https://docs.flutter.dev
- Comunidade: https://stackoverflow.com/questions/tagged/flutter
- Discord Flutter Brasil: https://discord.gg/flutter-brasil

---

**Dica final:** Na primeira vez que rodar, o Flutter baixa muitas dependências e pode demorar 10-15 minutos. Nas próximas vezes será muito mais rápido! ⚡
