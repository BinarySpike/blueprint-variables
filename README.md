# Blueprint Variables
** Alpha release **
A mod for the game Factorio.
This adds item, fluid, and circuit signals to the game that when blueprinted, provides an interface to quickly apply changes to all circuit, logistic, filter, train station names, and train schedules.

## Known Issues:
- Logistic chests cannot have multiple requests for the same item.  If you use an item variable and then an item stack variable, the first one found will be filled in and the duplicates will be mostly unchanged
- Trains do not blueprint by default, after blueprinting an area, you have to checkbox "Trains" in the "Set up new blueprint" menu.  Also, you probably want to checkbox "Train stop names".
- As a factorio mod api constraint, train schedules cannot be set while the locomotive is a ghost.  Having construction bots build the locomotive before you click "Apply" will allow the schedule and schedule stop names be updated.  A workaround is being developed.
- Cargo wagon filters do not work due to the above issue.  A workaround is being developed.