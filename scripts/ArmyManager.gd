extends Node

var agents:Array = []
const PLAYER_AGENT_SCENE :PackedScene = preload("res://scenes/tmp/player_agent.tscn")

func send_agent(hashed_name:String,target_position:Vector2):
	if agents.size() >= 10:
		printerr("Max agents deployed")
		return
	_add_agent(hashed_name,target_position)

func _add_agent(hashed_name:String,target_position:Vector2):
	var player_agent:CharacterBody2D = PLAYER_AGENT_SCENE.instantiate()
	player_agent.target_position = target_position
	player_agent.position = PlayerData.capital_location
	player_agent.host_country = hashed_name
	player_agent.name = "agent_" + str(agents.size())
	agents.append(player_agent)
	get_tree().get_first_node_in_group("AgentsParent").add_child(player_agent)

func remove_agent(agent:CharacterBody2D):
	if not is_instance_valid(agent):
		printerr("Agent is not valid anymore")
		return
	agents.erase(agent)
	agent.queue_free()
