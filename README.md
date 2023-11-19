# Blueprint Variables
** Alpha release **
A mod for the game Factorio.
This adds item, fluid, and circuit signals to the game that when blueprinted, provides an interface to quickly apply changes to all circuit, logistic, filter, train station names, and train schedules.

## Known Issues:
- Logistic chests cannot have multiple requests for the same item.  If you use an item variable and then an item stack variable, the first one found will be filled in and the duplicates will display as the variable
- Trains do not blueprint by default, after blueprinting an area, you have to checkbox "Trains" in the "Set up new blueprint" menu.  Also, you probably want to checkbox "Train stop names".
- Pasting blueprints over existing entities will replace (reset) the (variable'ized) conditions on the entities but the the variables will never update.  Mods cannot detect this, thus you have to remove all entities that you will be pasting over with variables.