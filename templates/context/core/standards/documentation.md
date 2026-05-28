# Documentation Standards

## Idioma

- **Espanol** siempre: analisis, respuestas, comentarios, commits, documentacion
- Terminos tecnicos en ingles OK (async, delegate, middleware, etc.)

## Tone

- Conciso, alto valor informativo
- Profesional pero accesible
- Explicar "por que" no solo "que"
- Senalar riesgos y edge cases proactivamente

## README / AGENTS.md

```
# [Nombre Proyecto]

## Stack
- .NET 8 / ASP.NET Core MVC
- Entity Framework, SQL Server
- Radzen Blazor UI
- SignalR para tiempo real

## Requisitos
- .NET 8 SDK
- SQL Server 2022+
- Node.js 18+

## Build & Run
```bash
dotnet restore
dotnet build
dotnet run
```

## Testing
```bash
dotnet test
```
```

## XML Comments (C#)

```csharp
/// <summary>
/// [Que hace]
/// </summary>
/// <param name="nombreParam">[Descripcion parametro]</param>
/// <returns>[Descripcion retorno]</returns>
/// <exception cref="TipoExcepcion">[Cuando se lanza]</exception>
```

## Commits

Formato: `tipo(scope): mensaje`

- `feat`: Nueva funcionalidad
- `fix`: Correccion de bug
- `refactor`: Cambio sin funcionalidad nueva
- `docs`: Solo documentacion
- `test`: Solo tests
- `chore`: Mantenimiento, CI, config

## Estructura

- Primera linea: ≤72 chars
- Cuerpo: explicar QUE y POR QUE
- NO incluir "como" (el codigo ya lo muestra)
