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
	Behavior defines the message handling behavior of an actor.
	This is a function pointer type that is invoked whenever an actor receives a message.

	Inputs:
	- p_actor_system: A pointer to the ActorSystem that manages the current actor and other actors in the system.
	- p_actor:        A pointer to the actor that is receiving the message, allowing the actor's state to be modified if needed.
	- message:        The message that is being passed to the actor, containing information or commands for the actor to process.
*/
Behavior :: proc( p_actor_system: ^ActorSystem, p_actor: ^Actor, message: Message )

/*
	Actor is the core structure representing an actor in the system.
	Each actor has its own state, behavior, and mailbox for processing messages.

	Fields:
	- ref:      A unique reference (ActorRef) to this actor.
	- state:    An ActorState, representing the internal state of the actor.
	- behavior: A Behavior function that defines how the actor processes incoming messages.
	- mailbox:  A dynamic array of Message structs, representing the actor's incoming message queue.
*/
Actor :: struct
{
    ref:      ActorRef,
    state:    ActorState,
    behavior: Behavior,
	mailbox:  [dynamic]Message
}

/*
	actor_destroy is responsible for deallocating an actor’s resources.
	It clears the actor's mailbox and frees the memory occupied by the actor itself.

	Inputs:
	- p_actor: A pointer to the actor that is to be destroyed.
*/
actor_destroy :: proc( p_actor: ^Actor )
{
	delete( p_actor.mailbox )
	free( p_actor )
}