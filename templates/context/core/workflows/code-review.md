# Code Review Workflow

## Proposito

Revisar codigo contra estandares del proyecto, identificar bugs, riesgos de seguridad, y mejorar mantenibilidad.

## Checklist Obligatorio

### Funcionalidad
- [ ] Implementa lo requerido (sin sobre-ingenieria)
- [ ] Edge cases manejados (null, vacio, limites)
- [ ] Validacion de datos de entrada
- [ ] Mensajes de error informativos

### Seguridad
- [ ] SQL Injection: usar parametros, NO concatenacion
- [ ] XSS: escapar output en views
- [ ] AntiForgeryToken en forms POST
- [ ] Autorizacion: `[Authorize]` donde aplica
- [ ] No hardcodear secrets/connection strings

### Performance
- [ ] Queries async (no bloqueantes)
- [ ] `AsNoTracking()` para solo lectura EF
- [ ] No N+1 queries (usar Include)
- [ ] Cache para datos poco volatiles

### Mantenibilidad
- [ ] XML comments en metodos publicos
- [ ] Naming claro y consistente
- [ ] Sin magic numbers/strings
- [ ] Complejidad ciclomatica razonable
- [ ] Sin comentarios de codigo muerto

### Tests
- [ ] Tests para logica nueva
- [ ] Tests existentes pasan
- [ ] Cobertura de edge cases

## Formato de Review

```
## Archivo: [path]

### 👍 Positivo
- [lo que esta bien]

### ⚠ Observaciones
- [linea X]: [problema] → [sugerencia]

### ❌ Bloqueantes
- [debe corregirse antes de merge]

### 💡 Sugerencias
- [mejora opcional]
```

## Criterios de Aprobacion

| Severidad | Accion |
|-----------|--------|
| Bloqueante | No aprobar hasta corregir |
| Observacion | Discutir, no bloquea |
| Sugerencia | Opcional, puede ser future work |
