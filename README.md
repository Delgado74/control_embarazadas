# PAMI-MF: Programa Materno Infantil de Medicina Familiar

Aplicación móvil para el control integral de mujeres embarazadas y lactantes en el Sistema Nacional de Salud de Cuba.

## Descripción General

PAMI-MF es una herramienta desarrollada en **Flutter** diseñada específicamente para el **Programa Materno Infantil de Medicina Familiar** del Sistema Nacional de Salud de Cuba. Permite el control integral de:

- **Embarazadas**: Registro completo, seguimiento prenatal, evoluciones médicas, clasificación de riesgo obstétrico (factores ARO/BRO)
- **Lactantes (menores de 1 año)**: Registro postnatal, evoluciones, seguimiento del desarrollo infantil

## Contexto: Sistema de Salud Cubano

La aplicación está diseñada para integrarse en la estructura organizativa del Sistema Nacional de Salud de Cuba:

- **Médico de Familia / Consultorio**: Nivel primario de atención
- **Grupos Básicos de Trabajo (GBT)**: Unidade básica de atención primaria
- **Policlínicos**: Nivel secundario de atención
- **Niveles municipal y provincial**: Dirección y supervisión territorial

## Características Principales

### Gestión de Embarazadas
- Registro de datos personales y de contacto
- Antecedentes familiares y personales
- Clasificación de factores de riesgo ARO (alto riesgo obstétrico) y BRO (bajo riesgo obstétrico)
- Cálculo automático de tiempo gestacional y cálculo de masa corporal (IMC)
- Seguimiento prenatal con evoluciones
- Programación de citas médicas

### Gestión de Lactantes
- Registro de datos del recién nacido
- Información del embarazo y parto
- Evoluciones postnatales
- Seguimiento del desarrollo (peso, talla, perímetro cefálico)
- Vacunación y alimentación

### Gestión por Consultorios
- Organización de pacientes por consultorio/médico
- Identificación única de cada registro (UUID)
- Filtrado y búsqueda de pacientes

## Arquitectura de Seguridad y Confidencialidad

| Aspecto | Implementación |
|---------|----------------|
| **Almacenamiento** | SQLite local en el dispositivo |
| **Acceso** | Solo profesionales de salud autorizados |
| **Transmisión** | Exportación manual controlada mediante JSON |
| **Identificación** | UUIDs únicos que permiten integración sin duplicación |

### Principio Fundamental

Los datos **nunca salen del consultorio** excepto mediante exportación controlada por el profesional de salud. Cada consultorio tiene control exclusivo y confidencial de su información.

## Sistema de Integración Jerárquica

```
┌────────────────────────────────────────────────────────────────────┐
│                     CONSULTORIO (Nivel Base)                       │
│  └── Médico de Familia / GBT                                       │
│      └── Control directo de embarazadas y lactantes               │
│      └── Exporta JSON con IDs únicos                               │
└────────────────────────────────────────────────────────────────────┘
                                  ↓
┌────────────────────────────────────────────────────────────────────┐
│                         GBT / POLICLÍNICO                          │
│  └── Recibe bases de datos de consultorios subordinados            │
│  └── Integra datos sin duplicación (IDs únicos)                   │
│  └── Consolida estadísticas del territorio                          │
└────────────────────────────────────────────────────────────────────┘
                                  ↓
┌────────────────────────────────────────────────────────────────────┐
│                    NIVEL MUNICIPAL / PROVINCIAL                   │
│  └── Agregación escalonada de datos                                │
│  └── Supervisión y control de calidad                              │
│  └── Generación de indicadores epidemiológicos                     │
└────────────────────────────────────────────────────────────────────┘
```

### Flujo de Información

1. Cada consultorio mantiene su base de datos local independiente
2. El responsable exporta la base de datos en formato JSON
3. El nivel superior importa los datos y se integran automáticamente
4. Los UUIDs evitan duplicación de registros
5. La información fluye de manera dinámica y ordenada hacia los niveles de dirección

## Continuidad del Trabajo

Una de las características más importantes es la **garantía de continuidad**:

| Escenario | Solución |
|-----------|----------|
| **Médico deja consultorio** | Entrega la base de datos al sucesor |
| **GBT cambia de responsable** | Exporta JSON y el nuevo responsable importa |
| **Cambio en cualquier nivel** | La información sigue al cargo, no a la persona |

> La información no se pierde nunca: todo el historial de pacientes, evoluciones, citas y datos clínicos queda disponible de inmediato para el nuevo responsable.

## Escalabilidad

- **Sin límite de consultorios**: Cada APK es independiente y puede agregarse sin reestructurar
- **Sin conexión a internet**: Funciona en áreas remotas sin conectividad
- **Crecimiento orgánico**: Se incorporan nuevos consultorios de forma natural
- **Base de datos SQLite**: Maneja miles de registros de manera eficiente
- **Exportación/Importación**: Permite consolidación de datos entre dispositivos

## Tecnología

- **Framework**: Flutter (multiplataforma: Android, iOS, Web, Desktop)
- **Lenguaje**: Dart
- **Base de datos**: SQLite (sqflite)
- **Dependencias**:
  - sqflite: Base de datos local
  - path_provider: Rutas del sistema de archivos
  - share_plus: Compartir archivos
  - file_picker: Seleccionar archivos
  - intl: internacionalización y fechas
  - uuid: Identificadores únicos

## Open Source y Colaboración

El proyecto está preparado para ser compartido como **software libre**, permitiendo:

1. **Desarrollo distribuido**: Contribuidores de diferentes territorios pueden mejorar la aplicación
2. **Adaptaciones locales**: Cada provincia puede personalizar según necesidades específicas
3. **Transparencia**: Código auditable por la comunidad médica y técnica
4. **Sostenibilidad**: No dependencia de un solo proveedor
5. **Colaboración comunitaria**: Mejoras propuestas por usuarios del sistema

### Posibilidades de Evolución
- API de sincronización en la nube (opcional)
- Módulo de telemedicina
- Dashboard analítico para autoridades de salud
- Integración con otros sistemas del MINSA
- Reportes epidemiológicos automatizados

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                  # Modelos de datos
│   ├── embarazada.dart      # Modelo de embarazada
│   ├── lactante.dart        # Modelo de lactante
│   ├── cita.dart            # Modelo de cita
│   ├── evolucion.dart       # Modelo de evolución
│   └── evolucion_lactante.dart
├── database/
│   └── database_helper.dart # Gestión de SQLite
└── screens/                 # Interfaces de usuario
    ├── home_screen.dart
    ├── gestantes_screen.dart
    ├── lactantes_screen.dart
    ├── embarazada_form.dart
    ├── lactante_form.dart
    ├── embarazada_detail.dart
    ├── lactante_detail.dart
    └── export_import_screen.dart
```

## Uso

1. **Registro**: Agregar nuevas embarazadas o lactantes
2. **Seguimiento**: Registrar evoluciones y citas
3. **Clasificación**: Identificar factores de riesgo ARO/BRO
4. **Exportación**: Generar archivo JSON para compartir
5. **Importación**: Recibir datos de otros consultorios
6. **Sucesión**: Transferir información al cambiar de responsable

## Licencia

Este proyecto está licenciado bajo los términos de la [Licencia MIT](LICENSE).

---

**PAMI-MF**: Comprometidos con la salud materno infantil del pueblo cubano.
