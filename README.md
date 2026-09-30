# Crucigramas 🧩✏️ — Interactive Crossword Puzzle Game

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Category](https://img.shields.io/badge/Category-Word%20Puzzle-success)]()
[![Author](https://img.shields.io/badge/Studio-Inventus%20Tech-orange)]()

> **Crucigramas** es un videojuego interactivo de palabras cruzadas para móviles. Desarrollado con una arquitectura bidimensional personalizada, ofrece generación y navegación por celdas con soporte táctil, pistas inteligentes, una tienda virtual de ítems cosméticos y persistencia tolerante a interrupciones.

---

## 🌟 Características Principales

* **Cuadrícula Matricial Interactiva:**
  * Motor de celdas bidimensionales que gestiona el cruce de palabras horizontales y verticales.
  * Resaltado automático de la palabra activa, pistas cruzadas y teclado integrado en pantalla optimizado para crucigramas.
* **Sistema de Pistas & Asistencia Dinámica:**
  * Revelado de letras individuales, revelado de palabras completas o comprobación de errores.
  * Consumo de monedas virtuales que recompensa al usuario por resolver acertijos.
* **Economía Virtual & Tienda de Personalización:**
  * Acumulación de monedas mediante partidas completadas.
  * Tienda de temas visuales, estilos de celda y paquetes de crucigramas temáticos.
* **Persistencia Blindada de Borradores (*Draft Resumption*):**
  * Guardado exacto del estado de cada celda ingresada por el usuario y del cronómetro transcurrido.
  * Validación defensiva de límites de coordenadas para evitar excepciones de índice fuera de rango al restaurar tableros guardados.
  * Protección contra condiciones de carrera para no sobrescribir el saldo de monedas al arrancar la aplicación.

---

## 🏗️ Estructura del Código

```
Crucigramas/
├── lib/
│   ├── models/
│   │   ├── board_model.dart         # Matriz del crucigrama, definiciones y respuestas
│   │   ├── cell_model.dart          # Estado de cada celda (letra, bloqueada, revelada)
│   │   └── shop_item_model.dart     # Ítems y temas de la tienda
│   ├── services/
│   │   ├── game_state_provider.dart # Proveedor central de estado de juego, monedas y partidas
│   │   └── board_generator.dart     # Algoritmo de parsing y carga de crucigramas
│   ├── screens/
│   │   ├── game_screen.dart         # Tablero interactivo y teclado personalizado
│   │   ├── level_selection_screen.dart # Catálogo de niveles y dificultades
│   │   └── shop_screen.dart         # Tienda de personalización y monedas
│   └── main.dart                    # Configuración de tema e inyección de dependencias
```

---

## 🚀 Puesta en Marcha

```bash
cd Crucigramas
flutter pub get
flutter run
```

---

**Desarrollado por Inventus Tech Studio** • *Liderado por Samuel Henríquez*
