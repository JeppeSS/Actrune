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
	Each message contains both the sender's actor reference and the message content itself.

	Fields:
	- from:    A pointer to the Actor sending the message. This allows the recipient to know who sent the message.
	- content: The content of the message, represented by the MessageContent union, which can be a string or raw pointer.
*/
Message :: struct
{
    from:    ^Actor,
    content: MessageContent
}