class_name DiplomacyRelationship
## Represents how one country behaves in relation with given country.


var recipient_country: Country

## If true, the country grants explicit permission to the recipient
## to move their armies into their provinces.
var grants_military_access: bool = false

## If true, the country will move its armies into the recipient's
## provinces without permission.
var is_trespassing: bool = true

## If true, the country will unconditionally engage in combat with
## any of the recipient's armies.
var is_fighting: bool = true
