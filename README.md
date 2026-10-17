# af_oilwell

## Description
`af_oilwell` is an advanced oil extraction, refining, and logistics civilian job resource for AshFall RP. Forked from `keep-oilwell` by Swkeep, it features functioning oil pumpjacks in the Grand Senora Desert, crude oil extraction, refining processes into commercial fuel products, tanker truck logistics, and wholesale market delivery.

## Dependencies
* FiveM Server Artifact `10731` or higher
* [ox_lib](https://github.com/overextended/ox_lib)
* [oxmysql](https://github.com/overextended/oxmysql)
* [af_core](https://github.com/AshFallRP/af_core) (or `qbx_core`)
* [af_target](https://github.com/AshFallRP/af_target) (or `ox_target`)
* [af_inventory](https://github.com/AshFallRP/af_inventory) (or `ox_inventory`)

## Installation
1. Ensure dependencies (`ox_lib`, `af_core`, `af_target`, `af_inventory`) are started.
2. Place `af_oilwell` inside `resources/[ashfall]/`.
3. Add the start entry to your `server.cfg`:
   ```cfg
   ensure af_oilwell
   ```

## Configuration
Configured in `config.lua`:
* `Config.PumpjackLocations`: World coordinates and prop models for active desert oil pumpjacks.
* `Config.Refinery`: Processing recipes, crude oil input to refined fuel output ratios, and refining times.
* `Config.Delivery`: Tanker truck delivery routes, wholesale buyer docks, and economic payout tables.

## Features
* **Functional Oil Pumpjacks:** Animated oil pumpjack machinery with realistic mechanical sound effects and maintenance requirements.
* **Petrochemical Refining:** Turn extracted crude oil into refined gasoline, diesel, and industrial plastics.
* **Commercial Logistics:** Load fuel into specialized commercial tanker trailers and transport cargo across San Andreas for economic payout.
* **Integrated Economy:** Directly feeds refined fuel reserves into the `af_fuel` gas station network.

## Core Functions & Usage

### Start Oil Extraction
Interacts with an oil pumpjack station to begin pumping crude oil:
```lua
TriggerServerEvent('af_oilwell:server:startPumping', pumpjackId)
```

## Credits & Acknowledgements
* [Swkeep](https://github.com/swkeep) - Original `keep-oilwell` system mechanics and asset coordination.
* [AshFall RP](https://github.com/AshFallRP) - Framework integration, target compatibility, and economy rebalancing.
