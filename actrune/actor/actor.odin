package actor

/*
	ActorRef is a distinct type that represents a unique reference to an actor.
*/
ActorRef :: distinct u32

/*
	ActorState is a union that represents the state of an actor.

	Fields:
	- int:   Used to represent simple integer states.
	- rawptr: A raw pointer for more complex or custom state types.
*/
ActorState :: union
{
	int,
	rawptr
}

/*
	Behavior is a function pointer type that defines the message handling behavior of an actor.
	When a message is sent to an actor, this handler is invoked.

	Inputs:
	- p_actor:  A pointer to the actor receiving the message.
	- message:  The message being passed to the actor.
*/
Behavior :: proc( p_actor: ^Actor, message: Message )

/*
	Actor is the core structure representing an actor in the system.

	Fields:
	- ref:      A unique reference (ActorRef) to this actor.
	- state:    An ActorState, representing the internal state of the actor.
	- behavior: A Behavior function that defines how the actor processes incoming messages.
*/
Actor :: struct
{
    ref:      ActorRef,
    state:    ActorState,
    behavior: Behavior
}

/*
	Sends a message from one actor to another by invoking the recipient's behavior function.

	Inputs:
	- p_from_actor: A pointer to the actor sending the message.
	- p_to_actor:   A pointer to the actor receiving the message.
	- content:      The content of the message being passed between actors.

	This function wraps the message with the sender's reference and forwards it to the recipient's behavior.
*/
actor_send_message :: proc( p_from_actor: ^Actor, p_to_actor: ^Actor, message: Message )
{
    p_to_actor.behavior( p_to_actor, Message{ from = p_from_actor, content = message.content } )
}