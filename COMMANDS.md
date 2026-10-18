# af_oilwell - Commands Reference

| Command | Arguments | Who | Description |
| :--- | :--- | :--- | :--- |
| `/create` | `oilwell` | `admin` (QBCore permission) | Start placing a new oil well (aim the laser, `E` to place). The CEO then assigns it to a player. |
| `/togglejob` | None | `admin` | Re-sends your oil company duty state. |

## Items and interactions

| What | How |
| :--- | :--- |
| `oilwell` item | Use it to place an oil well (consumed). |
| Assign / adjust a placed well | af_target on the well: "Assign to player" / "Adjust position" (CEO, grade 4, on duty). |
| Operate a well, storage, CDU, blender, withdraw, transport | af_target at each location (oil company job, on duty). |
| Repair parts | Use them at a broken well. |
| Duty | af_target at the `toggle_job` point. |
