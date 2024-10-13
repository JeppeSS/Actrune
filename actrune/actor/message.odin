package actor

/*
	MessageContent is a union representing the contents of a message.

	Fields:
	- string: A message represented as a string.
	- rawptr: A raw pointer to more complex message types.
*/
MessageContent :: union
{
    string,
    rawptr
}

/*
	Message is a structure representing the message passed between actors.

	Fields:
	- content: The content of the message, represented by the MessageContent union.
*/
Message :: struct
{
    content: MessageContent
}