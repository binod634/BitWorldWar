extends RefCounted
class_name ProductionUnitData

enum UnitType {
	Infantry,
	Tanks,
	Airforce,
	Navy,
	Submarine
}

var unitName:String
var unitType:UnitType
var unitCost:String
var buildingRequirement:String
var productionTimeline:String

# Constructor requiring all arguments
func _init(_unitName: String,_unitType:UnitType, _unitCost: String, _buildingRequirement: String, _productionTimeline: String) -> void:
	unitName = _unitName
	unitCost = _unitCost
	buildingRequirement = _buildingRequirement
	productionTimeline = _productionTimeline
	unitType = _unitType
