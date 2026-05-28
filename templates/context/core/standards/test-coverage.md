# Test Coverage Standards

## Framework

- Usar framework existente del proyecto (MSTest, NUnit, xUnit)
- NO cambiar framework sin autorizacion
- Usar fluent assertions si ya estan en el proyecto

## Patrones

### Arrange-Act-Assert (AAA)
```csharp
[Test]
public async Task CrearPedido_CuandoDatosValidos_RetornaExito()
{
    // Arrange
    var pedido = new Pedido { ... };
    
    // Act
    var result = await _service.CrearAsync(pedido);
    
    // Assert
    Assert.IsTrue(result.IsSuccess);
}
```

### Naming
- `[Metodo]_[Condicion]_[ResultadoEsperado]`
- En espanol
- Descriptivo, no generico

### Casos obligatorios
1. Happy path (caso exitoso)
2. Datos invalidos (validacion)
3. Null checks
4. Edge cases (limites, vacio)
5. Excepciones esperadas

## Cobertura

- Metodos publicos: ≥80% cobertura
- Metodos privados: no testear directamente (testear via publicos)
- Logica de negocio: prioridad alta
- CRUD simple: smoke test
- UI/Views: no requiere test unitario (test E2E si existe)

## Mocking

- Mockear SOLO dependencias externas (DB, API, filesystem)
- NO mockear metodos de la misma clase
- Usar framework existente (Moq, NSubstitute, etc.)

## Data-Driven Tests

```csharp
[TestCase("input1", true)]
[TestCase("input2", false)]
[TestCase("", false)]
public void ValidarFormato_CuandoInput_RetornaEsperado(string input, bool esperado)
{
    var result = _validator.Validar(input);
    Assert.AreEqual(esperado, result);
}
```

## Lo que NO testear
- Código generado (scaffolding, migrations)
- Configuracion pura (connection strings, settings)
- Propiedades simples (get/set sin logica)
- UI/Views (sin E2E)

## CI

- Tests deben pasar en `dotnet test --configuration Release`
- NO commitear con tests fallando
- Ejecutar local antes de push
