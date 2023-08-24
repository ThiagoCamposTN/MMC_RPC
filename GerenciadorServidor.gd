extends Node

signal cliente_se_conectou(id, nome)

const PORTA_PADRAO 		= 7000
const IP_LOCAL 			= "127.0.0.1" # IPv4 localhost
const CONEXOES_MAXIMA 	= 20
const ID_SERVIDOR 		= 1

var clientes = {}
var cliente_info = {}

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
	
	cliente_info = {"nome": "Servidor"}
	clientes["1"] = cliente_info

func _cliente_se_conectou(id):
	var nome = nomear_cliente()
	adicionar_cliente_a_lista(id, nome)
	var ip_do_cliente = get_tree().network_peer.get_peer_address(id)
	emit_signal("cliente_se_conectou", nome, ip_do_cliente)

func nomear_cliente():
	var quantia_clientes = len(clientes)
	return "Cliente_{0}".format([quantia_clientes])

func adicionar_cliente_a_lista(id, nome):
	var informacao_cliente = {}
	informacao_cliente["nome"] = nome
	clientes[id] = informacao_cliente
