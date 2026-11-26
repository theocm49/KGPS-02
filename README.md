# kGPS-Locator — Flutter Geolocator

Projeto de estudo baseado no PDF **Flutter - Geolocator** enviado pelo usuário.

## O que está implementado

- Scaffold com AppBar `kGPS-Locator`.
- Bússola desenhada com `CustomPainter`.
- Leitura do heading pelo pacote `flutter_device_compass`.
- Leitura contínua de latitude, longitude e altitude com `geolocator`.
- Solicitação e tratamento das permissões de localização.
- Waypoints iniciais WP001, WP002 e WP003.
- LongPress em waypoint para entrar no estado visual de navegação.
- Swipe para excluir waypoint.
- Botão STOP para sair da navegação.
- Atualização e cancelamento das subscriptions no ciclo de vida do widget.

**Observação sobre o roteiro:** na Etapa 1, o PDF determina que a criação por modal e o cálculo/seta de bearing ainda não sejam implementados. Por isso, `Add Waypoint` registra a ação e exibe uma mensagem, mantendo o escopo do material. A distância permanece fictícia (`-- m`), conforme o escopo da Etapa 1 do roteiro.

## Requisitos

- Flutter 3.24+ (recomendado Flutter 3.44+)
- Dart 3.5+
- Android ou iOS para testar GPS e bússola. Sensores não funcionam integralmente em todos os emuladores.

## Abrir e executar no VS Code

1. Extraia o ZIP.
2. Abra a pasta `kGPS-Locator` no VS Code (`File > Open Folder`).
3. Abra o terminal integrado (`Terminal > New Terminal`).
4. Execute:

```bash
flutter create . --platforms=android,ios
flutter pub get
flutter run
```

Se `flutter create .` perguntar sobre sobrescrever arquivos, mantenha os arquivos de plataforma gerados pelo Flutter e depois confira as permissões abaixo.

## Permissões Android

No arquivo `android/app/src/main/AndroidManifest.xml`, adicione como filhos diretos de `<manifest>` e antes de `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

O arquivo de exemplo incluído já mostra essas permissões. Se você executar `flutter create .`, confira se elas continuam presentes.

## Permissões iOS

No `ios/Runner/Info.plist`, dentro de `<dict>`, adicione as chaves do arquivo `ios/Runner/Info-Location-Snippet.plist`.

## Teste no Android Emulator

- Inicie o emulador e execute o app.
- Conceda a permissão de localização quando solicitada.
- Para simular uma coordenada: menu `...` do emulador > **Location** > escolha um ponto > **Save Point** > **Set Location**.
- Para testar a orientação: `...` > **Virtual Sensors** > ajuste **Magnetic Field**.
- Para testar navegação: pressione e segure um waypoint.
- Para parar: toque em **STOP**.
- Para excluir: deslize um waypoint para a esquerda.

## Dependências

- `geolocator: ^14.1.2`
- `flutter_device_compass: ^2.2.0`

## Commits sugeridos pelo material

```bash
git add .
git commit -m "Inicialização do projeto"
git commit -m "ADD Classe Waypoint"
git commit -m "ADD Widget Compass"
git commit -m "Finalização de Layout. Interface e funcionalidades fictícias."
git commit -m "Captura dos dados dos sensores e atualização de interface."
```

Os commits acima são sugestões de histórico. Execute-os em etapas se precisar demonstrar a evolução do trabalho.
