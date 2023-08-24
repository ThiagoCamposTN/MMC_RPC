extends Control

func _ready():
	GerenciadorServidor.connect("cliente_se_conectou", self, "atualizar_lista_de_clientes")
	$Principal.show()
	$Cliente.hide()
	$Servidor.hide()

func _on_Servidor_pressed():
	$Principal.hide()
	$Servidor.show()
	
	var porta 	= GerenciadorServidor.PORTA_PADRAO
	var resultado = GerenciadorServidor.criar_sala(porta)
	
	if resultado:
		print("erro: {0}".format([resultado]))

func _on_Cliente_pressed():
	$Principal.hide()
	$Cliente.show()
	
	var ip 		= GerenciadorServidor.IP_LOCAL
	var porta 	= GerenciadorServidor.PORTA_PADRAO
	
	var resultado = GerenciadorServidor.entrar_na_sala(ip, porta)
	
	if resultado:
		print("erro: {0}".format([resultado]))

func _on_Enviar_pressed():
	var numero1 = int($Cliente/VBoxContainer/HBoxContainer2/TextEdit.text)
	var numero2 = int($Cliente/VBoxContainer/HBoxContainer2/TextEdit2.text)
	rpc_id(GerenciadorServidor.ID_SERVIDOR, "calcular_com_servidor", numero1, numero2)

func atualizar_lista_de_clientes(nome, ip):
	var informacao_completa = "{0} - {1}".format([nome, ip])
	$Servidor/VBoxContainer/ListaClientes.add_item(informacao_completa)

func calcular_mmc(numero1, numero2):
	var mult_numero1 = range(numero1, (numero1*numero2) + numero1, numero1)
	var mult_numero2 = range(numero2, (numero1*numero2) + numero2, numero2)
	
	for x in mult_numero1:
		if x in mult_numero2:
			return x

func atualizar_resultado_servidor(numero1, numero2, resultado, tempo, nome):
	var texto = "{4}: ({0} us) MMC entre {1} e {2} é {3}".format([tempo, numero1, numero2, str(resultado), nome])
	$Servidor/VBoxContainer/Resultados.add_item(texto)

remote func calcular_com_servidor(numero1, numero2):
	var inicio_contador = OS.get_ticks_usec()
	var resultado 		= calcular_mmc(numero1, numero2)
	var fim_contador 	= OS.get_ticks_usec()
	var id_cliente 		= get_tree().get_rpc_sender_id()
	var nome_cliente = GerenciadorServidor.clientes[id_cliente]["nome"]
	atualizar_resultado_servidor(numero1, numero2, resultado, fim_contador - inicio_contador, nome_cliente)
	rpc_id(id_cliente, "enviar_resultado_para_cliente", resultado, fim_contador - inicio_contador)

remote func enviar_resultado_para_cliente(resultado, tempo):
	# atualizando o resultado no cliente
	$Cliente/VBoxContainer2/Resultado.text = str(resultado)
	$Cliente/VBoxContainer2/Resultado.text = str(resultado)
	$Cliente/VBoxContainer2/HBoxContainer2/Tempo.text = "{0} us".format([tempo])
