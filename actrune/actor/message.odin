package actor

/*
	Message_Content is a union representing the contents of a message.
	It can store either a simple string or a pointer to more complex message types.

	Fields:
	- string:  A message represented as a string.
	- rawptr:  A raw pointer to a more complex message type.
*/
Message_Content :: union
{
    string,
    rawptr
}

/*
	Message_Header contains metadata about a message.
	It is used to track the message type and the actor that sent the message.

	Fields:
	- type: A string representing the type of the message (e.g., "join", "chat", "leave").
	- from: An ActorRef representing the actor that sent the message, allowing the recipient to identify 
	        the sender and potentially send a response back.
*/
Message_Header :: struct
{
	type: string,
	from: ActorRef
}

/*
	Message is the primary structure that actors send to each other.
	Each message consists of two parts: a header that contains metadata about the message, and the actual content of the message.
	Messages are stored in actor mailboxes and processed one at a time.

	Fields:
	- header:  A Message_Header containing metadata about the message, including the type and the sender.
	- content: A Message_Content union that holds the actual message content, which can either be a string or a pointer 
	           to more complex data types.
*/
Message :: struct
{
    header: Message_Header,
    content: Message_Content
}

/*
	Message_Payload is a simplified structure designed to make it easier for actors to send messages.
	It only requires the message type and content, and the system will automatically handle additional metadata like the sender (`from` field).

	Fields:
	- type:    A string representing the type of the message (e.g., "join", "chat", "leave").
	- content: A Message_Content union containing the actual message content. This can be a string or a more complex type.
*/
Message_Payload :: struct
{
	type: string,
	content: Message_Content
}