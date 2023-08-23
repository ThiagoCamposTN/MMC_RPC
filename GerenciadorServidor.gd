extends Node

# These signals can be connected to by a UI lobby scene or the game scene.
signal cliente_se_conectou(id, nome)

const PORTA_PADRAO 		= 7000
const IP_LOCAL 			= "127.0.0.1" # IPv4 localhost
const CONEXOES_MAXIMA 	= 20
const ID_SERVIDOR 		= 1

# This will contain player info for every player, with the keys being each player's unique IDs.
var clientes = {}

# This is the local player info. This should be modified locally before the connection is made.
# It will be passed to every other peer.
# For example, the value of "name" can be set to something the player entered in a UI scene.
var cliente_info = {"nome": "Servidor"}

var players_loaded = 0

func _ready():
	get_tree().connect("network_peer_connected", self, "_cliente_se_conectou")

func entrar_na_sala(endereco, porta):
	var peer = NetworkedMultiplayerENet.new()
	var erro = peer.create_client(endereco, porta)
	if erro:
		return erro
	get_tree().network_peer = peer


func criar_sala(porta):
	var participante = NetworkedMultiplayerENet.new()
	var erro = participante.create_server(porta, CONEXOES_MAXIMA)
	if erro:
		return erro
	get_tree().network_peer = participante
	
	clientes["1"] = cliente_info

func _cliente_se_conectou(id):
#	print("Um novo cliente se conectou com o ID: ", id)
	var nome = nomear_cliente()
	adicionar_cliente_a_lista(id, nome)
	rpc("atualizar_lista_de_clientes", clientes)
	var ip_do_cliente = get_tree().network_peer.get_peer_address(id)
	emit_signal("cliente_se_conectou", nome, ip_do_cliente)

func nomear_cliente():
	var quantia_clientes = len(clientes)
	return "Cliente_{0}".format([quantia_clientes])

func adicionar_cliente_a_lista(id, nome):
	var informacao_cliente = {}
	informacao_cliente["nome"] = nome
	clientes[id] = informacao_cliente

func atualizar_lista_de_clientes(clientes):
	self.clientes = clientes
	self.cliente_info = clientes[get_tree().network_peer.get_unique_id()]
