# Reglas de Arquitectura y Gobernanza Técnica

> **Proyecto:** Sistema Web en Flutter  
> **Patrón Arquitectónico:** Clean Architecture + Feature-First + Event-Driven Architecture (EDA)  
> **Entorno:** Flutter Web (Multiplataforma)

---

## 1. Declaración de Principios

Este documento establece los estándares innegociables de ingeniería y arquitectura de software para el desarrollo del sistema. Todo desarrollador o asistente de inteligencia artificial debe apegarse rigurosamente a estas directrices.

```
+-----------------------------------------------------------------------------------+
|                            CLIENTE WEB (FLUTTER WEB)                              |
|   lib/features/<feature>/presentation/ (Pages, Responsive Layouts, Controllers)   |
+-----------------------------------------------------------------------------------+
                                       |
                                       v  (Ejecuta Casos de Uso / Escucha EventBus)
+-----------------------------------------------------------------------------------+
|                           LÓGICA DE NEGOCIO Y EVENTOS                             |
|   lib/features/<feature>/domain/ (Entities, UseCases, Repositories Contracts)     |
|   lib/core/events/ (AppEventBus, DomainEvent)                                     |
+-----------------------------------------------------------------------------------+
                                       ^
                                       |  (Implementa Contratos de Repositorio)
+-----------------------------------------------------------------------------------+
|                              PERSISTENCIA Y DATOS                                 |
|   lib/features/<feature>/data/ (Models/DTOs, Remote/Local DataSources, ReposImpl) |
+-----------------------------------------------------------------------------------+
```

---

## 2. Organización del Código: Feature-First

El proyecto prohíbe taxativamente la organización tradicional por capas horizontales globales (como tener carpetas globales `views/`, `controllers/`, `services/`).

La estructura raíz de código en `lib/` es:

```text
lib/
├── core/                        # Elementos transversales y utilitarios globales
│   ├── errors/                  # Fallos (Failures), excepciones y Result<T>
│   ├── events/                  # Bus de eventos y tipos base para EDA
│   ├── network/                 # Clientes HTTP, interceptores, headers
│   ├── responsive/              # Breakpoints y helpers para Flutter Web
│   ├── theme/                   # Colores, tipografía y estilos globales
│   └── usecases/                # Interfaces base para Casos de Uso
│
├── features/                    # Módulos funcionales de negocio
│   └── <feature_name>/
│       ├── domain/              # Dominio puro (Cero dependencias externas)
│       │   ├── entities/
│       │   ├── events/
│       │   ├── repositories/    # Interfaces / contratos abstractos
│       │   └── usecases/
│       │
│       ├── data/                # Implementación técnica y persistencia
│       │   ├── datasources/
│       │   ├── models/          # DTOs y mapeadores a Entidades
│       │   └── repositories/    # Implementaciones de repositorios
│       │
│       └── presentation/        # Interfaz de usuario Web y estado
│           ├── controllers/     # Manejo de estado reactivo
│           ├── pages/           # Vistas web responsivas
│           └── widgets/         # Widgets atómicos de la funcionalidad
│
└── main.dart                    # Punto de entrada e inicialización de servicios
```

---

## 3. Clean Architecture por Módulo: Reglas de Dependencia

### 3.1. Capa de Dominio (`domain/`)
- **Regla Fundamental:** Es el núcleo del sistema y debe ser 100% código Dart puro.
- **Prohibiciones:**
  - PROHIBIDO importar `package:flutter/...`.
  - PROHIBIDO importar librerías de base de datos, HTTP o utilidades de UI.
  - PROHIBIDO conocer la existencia de la capa de datos (`data/`) o de presentación (`presentation/`).

### 3.2. Capa de Datos (`data/`)
- **Regla Fundamental:** Implementa las interfaces declaradas en el dominio.
- **Obligaciones:**
  - Los modelos (`models/`) representan la estructura cruda (JSON, DTOs de API) y deben exponer métodos de conversión hacia las entidades del dominio (`toEntity()`) y desde ellas (`fromEntity()`).
  - Las fuentes de datos (`datasources/`) manejan exclusivamente la comunicación con APIs REST, GraphQL, WebSockets o almacenamiento local.

### 3.3. Capa de Presentación (`presentation/`)
- **Regla Fundamental:** Es la capa de entrada e interacción con el usuario en Flutter Web.
- **Obligaciones:**
  - Solo se comunica con la lógica de negocio mediante Casos de Uso (`UseCase`).
  - Nunca instancia ni consume directamente `DataSources` o `Repositories`.
  - Debe gestionar vistas responsivas para resoluciones Desktop, Tablet y Móvil.

---

## 4. Arquitectura Orientada a Eventos (EDA) entre Features

Para evitar el acoplamiento directo ("código espagueti") entre módulos:

1. **Aislamiento Total:**  
   Un feature jamás puede importar clases internas de otro feature.  
   ❌ `import 'package:proyecto/features/auth/presentation/controllers/auth_controller.dart';` (INCORRECTO)
2. **Eventos de Dominio:**  
   Cuando un evento relevante sucede en un módulo (por ejemplo, `UserLoggedInEvent`, `PaymentCompletedEvent`), el caso de uso o controlador emite el evento al `AppEventBus`.
3. **Suscripción Desacoplada:**  
   Cualquier otro módulo interesado escucha el stream del `AppEventBus` y ejecuta su propio caso de uso internamente sin conocer quién emitió el evento.

```text
[Feature A: Auth]
     │
     └── Emite: UserLoggedInEvent
              │
              ▼
    ╔═════════════════════╗
    ║   AppEventBus       ║
    ╚═════════════════════╝
              │
              ▼
       Escuchan de forma independiente:
     ┌────────────────────────┬────────────────────────┐
     ▼                        ▼                        ▼
[Feature B: Perfil]   [Feature C: Notif]      [Feature D: Auditoría]
```

---

## 5. Gobernanza Activa y Rol del Asistente

El asistente técnico actúa como **Arquitecto de Software Senior y Guardián del Repositorio**:
- Valida activamente que cada archivo creado pertenezca a la carpeta correcta y cumpla su rol.
- Se niega a introducir atajos técnicos o acoplamientos innecesarios.
- Promueve la inmutabilidad, el manejo robusto de errores mediante `Result<T, Failure>` y pruebas unitarias sin dependencias externas.
