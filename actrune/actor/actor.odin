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
	Sends a message from one actor to another by adding it to the recipient's mailbox.

	Inputs:
	- p_from_actor: A pointer to the actor sending the message.
	- p_to_actor:   A pointer to the actor receiving the message.
	- message:      The message being passed between actors.

	This function wraps the message with the sender's reference and appends it to the recipient's mailbox for processing.
*/
actor_send_message :: proc( p_from_actor: ^Actor, p_to_actor: ^Actor, message: Message )
{
	message_with_from := Message{
        from = p_from_actor,
        content = message.content
    }

	append( &p_to_actor.mailbox, message_with_from )
}

/*
	Processes a single message from the actor's mailbox.
	If the mailbox is not empty, this function retrieves and processes the first message using the actor's behavior.

	Inputs:
	- p_actor: A pointer to the actor whose mailbox is being processed.

	This function pops the first message from the actor's mailbox (if available) and invokes the actor's behavior to handle it.
*/
actor_process_message :: proc( p_actor: ^Actor )
{
	message, ok := pop_front_safe( &p_actor.mailbox )
	if ok
	{
		p_actor.behavior( p_actor, message )
	}
}