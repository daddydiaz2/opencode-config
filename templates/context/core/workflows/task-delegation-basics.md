# Task Delegation Basics

## Cuando delegar

| Condicion | Accion |
|-----------|--------|
| 4+ archivos involucrados | Delegar a TaskManager |
| Stack especializado (testing, docs) | Delegar a especialista |
| Revision multi-componente | Delegar a CodeReviewer |
| Tarea simple (1-3 archivos, <30min) | Ejecutar directo |
| Bug claro, un archivo | Ejecutar directo |

## Proceso

1. Analizar tarea → determinar tipo
2. Cargar contexto relevante (standards)
3. Crear context bundle en `.tmp/context/{session-id}/`
4. Delegar con instrucciones claras
5. Monitorear resultado
6. Validar output contra estandares

## Context Bundle (.tmp/context/{session-id}/bundle.md)

Incluir:
- Descripcion de la tarea y objetivos
- Archivos involucrados con paths
- Estandares a seguir (paths a .md)
- Restricciones y constraints
- Output esperado

## Delegacion a TaskManager

Para features complejas (multi-step, dependencias):
1. Crear `.tmp/sessions/{timestamp}-{task-slug}/context.md`
2. Delegar a TaskManager para breakdown
3. TaskManager genera `.tmp/tasks/{feature}/subtask_NN.json`
4. Ejecutar subtareas en paralelo segun dependencias

## Delegacion a Especialistas

Para tareas especificas (1-3 archivos):
- TestEngineer: `subagent_type="TestEngineer"` + context inline
- CodeReviewer: `subagent_type="CodeReviewer"` + checklist
- DocWriter: `subagent_type="DocWriter"` + format spec

## Errores comunes

- ❌ Delegar sin contexto (subagente no sabe estandares)
- ❌ Instrucciones ambiguas ("hazlo bien")
- ❌ No validar output contra estandares
- ✅ Contexto completo + instrucciones precisas + validacion
