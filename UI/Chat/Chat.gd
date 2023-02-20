extends Control
class_name Chat

@onready var allMessagesBox = $Panel2/VBoxContainer/Panel/MarginContainer/AllMessagesBox
@onready var sendMessageBox = $Panel2/VBoxContainer/HBoxContainer/SendMessageBox
@onready var sendMessageButton = $Panel2/VBoxContainer/HBoxContainer/SendButton

signal SendMessage(message:String)

@rpc("any_peer", "call_local")
func EmmitSendMessage(messageText:String):		
	SendMessage.emit(messageText)
	
func RenderMessages(messages: Array[Message]):
	allMessagesBox.clear()
	
	for message in messages:		
		allMessagesBox.add_text(message.PlayerName +": "+  message.MessageText)			
		allMessagesBox.newline()
	
func _on_send_button_pressed():
	_on_send_message_box_text_submitted(sendMessageBox.text)

func _on_send_message_box_text_submitted(new_text):
	EmmitSendMessage.rpc(new_text)
