# af_oilwell

## Description
AshFall RP's fork of [keep-oilwell](https://github.com/swkeep/keep-oilwell) by Swkeep: a NoPixel-inspired oil company. Players own and run pumpjacks that produce crude oil, refine it in a distillation unit (CDU), blend it into fuels, store and transport it, and sell it, with employees, breakdowns and repair parts.

On AshFall it runs on af_core (QBCore bridge), af_inventory, af_target and af_fuel.

## Features
- **Owned oil wells:** spawned from the `oilwell` item or `/create oilwell`, placed with a laser preview, then assigned to a player by the company CEO (`oilwell` job, grade 4, on duty).
- **Pumpjack operation:** speed, temperature and duration per well; wells wear out (belt, polish, clutch) and stop until fixed with parts (`reliefvalvestring`, `oilfilter`, `skewgear`, `timingchain`, `driveshaft`).
- **Processing chain** (`Oilwell_config.locations`): storage, distillation (CDU, temperature-controlled), blender (recipes and octane), barrel withdraw, crude oil transport.
- **Withdraw:** fill `oilbarell` items (5,000 gal, $500) or order a truck from the withdraw NPC (`TruckWithdraw`).
- **Transport and sale:** sell oil types up to `Transport.max_stock` per type at `Transport.prices`; barrels are refunded.
- **Delivery job:** a rally truck run (`Delivery`) with a refund on return.
- **Employees:** owners hire players (they need the `oilwell` job); oil an employee transfers goes to the owner's storage; owners fire at will.
- **CEO tools:** the CEO can flag any well as deleted (recoverable).
- **Duty:** oil company employees must be on duty to operate wells (`toggle_job` point).
- **Server-side checks (AshFall):** placing a rig needs a one-time permit from the item or the admin command, valid coordinates within 150 m; assigning a rig needs the on-duty CEO and a real pumpjack.

## Todo
- [ ] Audit the remaining server callbacks in `server/server_main.lua` (pump speed, CDU, blender, withdraw, transport, employees): several act on the client's word without checking the oilwell job, duty or distance on the server, the same gap that `createNewOilrig` / `regiserOilrig` had.
- [ ] The server checks the oil company job and duty in only one place; operating wells "on duty" is enforced by the client's target options.
- [ ] Sell refined fuel into af_fuel stations through `exports.af_fuel:OffloadWholesaleFuel` (the export exists, nothing calls it yet).
- [ ] Move off the QBCore bridge (`QBCore.Functions.CreateCallback`, `QBCore.Commands.Add`) to ox_lib callbacks and `lib.addCommand`.
- [ ] `/togglejob` is admin-only (`QBCore.Commands.Add(..., 'admin')`) and just re-sends the duty state; check whether it's still needed.

## Exports
None. Everything runs through the resource's own callbacks, targets and menus.

## Dependencies
* [ox_lib](https://github.com/overextended/ox_lib), [oxmysql](https://github.com/overextended/oxmysql)
* [af_core](https://github.com/AshFallRP/af_core) (QBCore bridge: callbacks, commands, jobs)
* [af_target](https://github.com/AshFallRP/af_target), [af_inventory](https://github.com/AshFallRP/af_inventory), [af_fuel](https://github.com/AshFallRP/af_fuel) (a manifest dependency; nothing calls it yet)

## Installation
1. Tables (`oilrig_position`, `oilrig_storage`, `oilrig_cdu`, `oilrig_blender`, `oilcompany_employees`) are created on start; `sql.sql` has the same schema for manual import.
2. The items (`oilbarell`, `oilwell`, `reliefvalvestring`, `oilfilter`, `skewgear`, `timingchain`, `driveshaft`) are in af_inventory's `data/items.lua`; images are in `inventoryicons/`.
3. The `oilwell` job (grades 0-4, 4 = CEO, `isboss`) is in af_core's `shared/jobs.lua`.
4. `ensure af_oilwell` after its dependencies.

## Configuration (`config.lua`, `Oilwell_config`)
* `inventory_max_size`, `AnimationSpeedDivider`, `actionSpeed`; `fuel_script` (`'af_fuel'`) is not read by the code.
* `Settings`: storage size, well blip, `capacity` (barrel and truck size / cost).
* `locations`: `storage`, `distillation`, `blender`, `barrel_withdraw`, `toggle_job`, `crude_oil_transport`.
* `Delivery`, `Transport` (stock, prices, refunds), `TruckWithdraw` (NPC and box), `Locale`.

## Commands
See [COMMANDS.md](COMMANDS.md).

## Credits
- Forked from [swkeep/keep-oilwell](https://github.com/swkeep/keep-oilwell) by Swkeep (GPL-3.0).
- [AshFall RP](https://github.com/AshFallRP): af_* integration, ox_lib cache, server-side checks on rig placement and assignment.
