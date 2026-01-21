extends  Node


const resolution:Vector2 = Vector2(1280,720) * 2
const max_zoom:float = 4.0
const min_zoom_for_territory:float = 2
const min_zoom:float = 1.5
const allow_debug:bool  = true
const max_buildings:int = 1
const time_interval:float = 0.1
const time_scale:int = 1 # speed scale

enum BuildingType {
	ARMY_BASE,
	AIR_BASE,
	NAVAL_BASE,
	TANK_BASE,
}

var buildings:Dictionary[BuildingType,BuildingData] = {
	BuildingType.ARMY_BASE: preload('res://scripts/Data/army_base.tres'),
	BuildingType.NAVAL_BASE:preload('res://scripts/Data/naval_base.tres'),
	BuildingType.AIR_BASE:preload('res://scripts/Data/air_base.tres'),
	BuildingType.TANK_BASE:preload('res://scripts/Data/tank_base.tres'),
}
