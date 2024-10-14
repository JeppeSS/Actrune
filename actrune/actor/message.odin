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
	Message is a structure representing the message that actors send to each other.
	Each message consists of two parts: the actor who sent the message and the content of the message.
	Messages are used as the primary form of communication between actors and are processed one at a time from an actor's mailbox.

	Fields:
	- from:    An ActorRef representing the actor that sent the message. This allows the receiving actor to know the sender’s identity 
	           and potentially send a response back, enabling two-way communication.
	- content: The content of the message, which is stored in a MessageContent union. The content can either be a string or a raw pointer, 
	           depending on the type of message being passed. This flexibility allows for both simple and complex message structures.
*/
Message :: struct
{
    from:    ActorRef,
    content: MessageContent
}