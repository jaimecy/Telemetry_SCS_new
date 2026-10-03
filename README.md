# scs_telemetry_jaime

Plugin de telemetría SCS para **Euro Truck Simulator 2** y **American Truck Simulator**.

| | |
|---|---|
| **DLL** | `scs_telemetry_jaime.dll` |
| **Memoria compartida** | `Local\SCSTelemetry` (rev **12**) |
| **SDK** | SCS **1.14** (headers incluidos en `scs_sdk/`) |
| **Extra** | Soporte **ATS Road Trip** (`car_job` / `bus_job` / `car` / `bus`) |

Compatible con lectores que esperan el layout RenCloud (p. ej. TruckHUD / `truck-telemetry`).

Basado en [RenCloud/scs-sdk-plugin](https://github.com/RenCloud/scs-sdk-plugin).

## Uso rápido (sin compilar)

1. Descarga `Win64/scs_telemetry_jaime.dll`.
2. Con el juego **cerrado**, cópiala a:
   - `...\Euro Truck Simulator 2\bin\win_x64\plugins\`
   - o `...\American Truck Simulator\bin\win_x64\plugins\`
3. **Quita** cualquier `scs-telemetry.dll` antigua en esa carpeta (escriben la misma memoria).
4. Arranca el juego y acepta el diálogo del SDK de telemetría.

## Compilar

Requisitos: Visual Studio (C++) + Windows SDK.

```bat
build_release_x64.bat
```

Salida: `build\Release\scs_telemetry_jaime.dll` y copia en `Win64\`.

## Road Trip (ATS)

El juego publica encargos de coche/bus aparte del `job` de camión:

- Configs: `car_job`, `bus_job` (y vehículo `car` / `bus`)
- Eventos: `car_job.delivered` / `car_job.cancelled` (y equivalentes `bus_job.*`)
- Mercado: atributo `car_job.market` / `bus_job.market` (`quick_job`, `dispatch_job`, …)

Se tratan como un job normal (`onJob`, ciudades, carga, distancia planificada, etc.). Un `job` vacío de camión **no** apaga un `car_job`/`bus_job` activo (y al revés).

## Licencias

- Headers SCS SDK: `scs_sdk/sdk_license.txt` (MIT, SCS Software).
- Código del plugin: derivado de RenCloud/scs-sdk-plugin; ver `NOTICE.md`.
