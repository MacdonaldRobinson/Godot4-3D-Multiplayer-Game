extends Control

@onready var allMessagesBox = $Panel2/VBoxContainer/Panel/MarginContainer/AllMessagesBox
@onready var sendMessageBox = $Panel2/VBoxContainer/HBoxContainer/SendMessageBox
@onready var sendMessageButton = $Panel2/VBoxContainer/HBoxContainer/SendButton

var allMessages: Array[Message] =  []

signal SendMessage(message:Message)

@rpc("call_local", "any_peer")
func EmmitSendMessage(messageText:String):		
	var message:Message = Message.new()
		
	message.UserName = str(multiplayer.get_remote_sender_id())
	message.MessageText = messageText;
		
	allMessages.push_back(message)
	RenderMessages(allMessages)
	
func RenderMessages(messages: Array[Message]):
	allMessagesBox.clear()
	
	for message in allMessages:		
		allMessagesBox.add_text(message.UserName +": "+  message.MessageText)			
		allMessagesBox.newline()
	
func _on_send_button_pressed():
	_on_send_message_box_text_submitted(sendMessageBox.text)

func _on_send_message_box_text_submitted(new_text):
	EmmitSendMessage.rpc(new_text)
