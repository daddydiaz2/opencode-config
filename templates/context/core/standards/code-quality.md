# Code Quality Standards

## General

- Escribir en español: comentarios, nombres de metodos, variables (donde tenga sentido)
- Usar `async/await` para toda operacion I/O (DB, filesystem, red)
- Inyectar dependencias por constructor
- NO hardcodear strings — usar constantes o settings

## C# Conventions

```csharp
/// <summary>
/// [Que hace — descripcion clara]
/// </summary>
/// <param name="param">[Que es]</param>
/// <returns>[Que devuelve]</returns>
/// <remarks>[Casos borde, notas]</remarks>
public async Task<T> MetodoAsync(TParam param)
{
    // Validar parametros
    ArgumentNullException.ThrowIfNull(param);
    
    // Logica principal
    var result = await _service.ProcesarAsync(param);
    
    return result;
}
```

- XML comments obligatorios en metodos publicos
- `var` preferido sobre tipo explicito
- Pattern matching donde aplicable
- Expression-bodied members para metodos simples

## Entity Framework

- Usar `async` queries: `ToListAsync()`, `FirstOrDefaultAsync()`
- `AsNoTracking()` para solo lectura
- Include/ThenInclude para eager loading
- Migraciones via CLI: `dotnet ef migrations add`

## ASP.NET Core

- Inyectar servicios via constructor
- Usar `[FromBody]`, `[FromQuery]`, `[FromRoute]` explicitamente
- TempData para mensajes UI: `TempData["Success"]`, `TempData["Error"]`
- AntiForgeryToken en todos los forms POST

## File Uploads

- Guardar en `wwwroot/uploads/{subfolder}/`
- Nombre archivo: `{tipo}_{username}_{id}_{timestamp}.{ext}`
- Path almacenado en DB, no el archivo

## Razor Views

- `@section Styles` para CSS custom
- `@section Scripts` para JS custom
- Dark mode via clase `.dark-mode` en body
- jQuery validation: `await Html.RenderPartialAsync("_ValidationScriptsPartial")`
- AntiForgeryToken: `@Html.AntiForgeryToken()`

## DataTables

- Idioma espanol: `/lib/datatables/js/es-ES.json`
- Tradicional pagination
- Inicializar en `$(document).ready()`

## SweetAlert2

- Confirmacion antes de delete
- Mensajes en espanol
- Iconos apropiados (warning, error, success)

## Firma Digital (SignaturePad)

- JS: `/lib/signature_pad/signature_pad.min.js`
- Canvas `id="signature-pad"`
- `signaturePad.toDataURL('image/png')` → base64
- Guardar en `wwwroot/uploads/firmas/`
