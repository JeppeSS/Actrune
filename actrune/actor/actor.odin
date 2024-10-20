package actor

import "core:fmt"

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
	ActorLifeState is an enum that defines the different stages of an actor's lifecycle.
	It allows the system to track and manage the state of each actor and transition between various stages.
*/
ActorLifeState :: enum u8
{
	Initialized = 0, // Actor has been created but not yet started.
	Running     = 1, // Actor is actively processing messages.
	Stopping    = 2, // Actor is in the process of stopping (e.g., during graceful shutdown).
	Stopped     = 3, // Actor has stopped but is not yet terminated.
	Restarting  = 4, // Actor is restarting due to a failure or supervisor intervention.
	Terminated  = 5  // Actor is permanently stopped and can no longer process messages.
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
	- life_state: An ActorLifeState enum value that represents the current lifecycle state of the actor, such as Running, Stopping, or Terminated.
*/
Actor :: struct
{
    ref:        ActorRef,
    state:      ActorState,
    behavior:   Behavior,
	mailbox:    [dynamic]Message,
	life_state: ActorLifeState
}

/*
	actor_init is responsible for initializing a new actor with the given reference, behavior, and initial state.
	It allocates memory for the actor, sets its initial properties (including the behavior and state), and places the actor in the `Initialized` lifecycle state.
	This function is typically called during actor creation to set up all the necessary properties before the actor can start running.

	Inputs:
	- ref:      An ActorRef representing the unique reference for this actor. This reference is used to identify the actor in the system.
	- behavior: A Behavior function that defines how the actor processes incoming messages. This function will be called whenever the actor receives a message.
	- state:    The initial state of the actor, represented as an ActorState.

	Returns:
	- A pointer to the newly created and initialized Actor.
*/
actor_init :: proc( ref: ActorRef, behavior: Behavior, state: ActorState ) -> ^Actor
{
	fmt.printfln( "Initializing actor %d...", ref )

    p_actor           := new( Actor )
    p_actor.ref        = ref
    p_actor.mailbox    = make( [dynamic]Message )
    p_actor.behavior   = behavior
    p_actor.state      = state
    p_actor.life_state = .Initialized

	fmt.printfln( "Actor %d is now initialized.", p_actor.ref )

	return p_actor
}

/*
	actor_start is responsible for starting an actor, transitioning it from either the 
	`Initialized` or `Restarting` state to the `Running` state. It checks the current 
	lifecycle state of the actor to ensure it is valid for starting.

	The function handles various actor states:
	- `Terminated`: If the actor is in this state, it cannot be started again, and an error message is logged.
	- `Stopped`: If the actor is stopped, the function suggests restarting instead of starting directly.
	- `Running`: If the actor is already running, no action is taken, and a message is logged.
	- `Initialized` or `Restarting`: The actor is transitioned to the `Running` state and a message is logged indicating that the actor has started.

	Inputs:
	- p_actor: A pointer to the actor that is to be started. The function checks the actor’s current `life_state` and transitions it to `Running` if appropriate.
*/
actor_start :: proc( p_actor: ^Actor )
{
	if p_actor.life_state == .Terminated
	{
		fmt.printfln( "Actor %d is terminated, cannot start", p_actor.ref )
		return
	}

	if p_actor.life_state == .Stopped
	{
		fmt.printfln( "Actor %d is stopped, cannot start directly. Consider restarting.", p_actor.ref )
		return
	}

	if p_actor.life_state == .Running 
	{
        fmt.printfln( "Actor %d is already running.", p_actor.ref )
        return
    }

	if p_actor.life_state == .Initialized || p_actor.life_state == .Restarting
	{
		fmt.printfln( "Starting actor %d...", p_actor.ref )
		p_actor.life_state = .Running
		fmt.printfln( "Actor %d is now running.", p_actor.ref )
	}
}

/*
	actor_graceful_stop is responsible for gracefully stopping an actor.
	It transitions the actor to the `.Stopping` state, allowing it to finish processing any pending messages in its mailbox.
	Once all messages are processed through the normal message processing loop, the actor will automatically transition to the `Stopped` state.

	Inputs:
	- p_actor: A pointer to the actor that is to be gracefully stopped.
*/
actor_graceful_stop :: proc( p_actor: ^Actor )
{
    if p_actor.life_state == .Terminated 
	{
        fmt.printfln( "Actor %d is terminated, cannot stop a terminated actor.", p_actor.ref )
        return
    }

    if p_actor.life_state == .Stopped
	{
        fmt.printfln( "Actor %d is already stopped.", p_actor.ref )
        return
    }

    if p_actor.life_state == .Running
	{
        fmt.printfln( "Gracefully stopping actor %d...", p_actor.ref )
        p_actor.life_state = .Stopping
        fmt.printfln( "Actor %d is now in stopping state.", p_actor.ref )
    }
}

/*
	actor_immediate_stop transitions an actor directly to the `Stopped` state without processing any remaining messages.
	It stops the actor immediately, regardless of any pending messages in its mailbox.

	Inputs:
	- p_actor: A pointer to the actor that is to be immediately stopped.
*/
actor_immediate_stop :: proc( p_actor: ^Actor )
{
    if p_actor.life_state == .Terminated
	{
        fmt.printfln( "Actor %d is terminated, cannot stop a terminated actor.", p_actor.ref )
        return
    }

    if p_actor.life_state == .Stopped
	{
        fmt.printfln( "Actor %d is already stopped.", p_actor.ref )
        return
    }

    if p_actor.life_state == .Running || p_actor.life_state == .Stopping
	{
        fmt.printfln( "Immediately stopping actor %d...", p_actor.ref )
        p_actor.life_state = .Stopped
        fmt.printfln( "Actor %d is now stopped.", p_actor.ref )
    }
}

/*
	actor_restart is responsible for restarting an actor by transitioning it through the `Restarting` state
	and then back to `Running`. The function resets the actor's state, allowing the actor to start fresh after the restart.

	Inputs:
	- p_actor: A pointer to the actor that is to be restarted.
*/
actor_restart :: proc( p_actor: ^Actor )
{
    if p_actor.life_state == .Terminated 
	{
        fmt.printfln( "Actor %d is terminated, cannot restart a terminated actor.", p_actor.ref )
        return
    }

    if p_actor.life_state == .Stopped || p_actor.life_state == .Running
	{
        fmt.printfln( "Restarting actor %d...", p_actor.ref )
        p_actor.life_state = .Restarting

		// TODO[Jeppe]: Find a way to reset the state.
        //p_actor.state = 

        actor_start( p_actor )
    }
}



/*
	actor_process_messages processes any messages in the actor's mailbox.
	This function is responsible for invoking the actor's behavior for each message and ensuring that the actor transitions to the `Stopped` state when it is in the `.Stopping` state and its mailbox is empty.

	Inputs:
	- p_actor_system: A pointer to the ActorSystem that manages the actor.
	- p_actor:        A pointer to the actor whose messages are being processed.
*/
actor_process_messages :: proc( p_actor_system: ^ActorSystem, p_actor: ^Actor )
{

	if p_actor.life_state == .Running || p_actor.life_state == .Stopping
	{
		message, ok := pop_front_safe( &p_actor.mailbox )
		if ok
		{
			p_actor.behavior( p_actor_system, p_actor, message )
		}

		if p_actor.life_state == .Stopping && len(p_actor.mailbox) == 0
		{
			fmt.printfln( "Actor %d has no pending messages, now stopped.", p_actor.ref )
			p_actor.life_state = .Stopped
		}
	}
}

/*
	actor_receive_message simulates the act of an actor receiving a message by placing it into its mailbox.
	It ensures that the actor is in a valid state to receive messages before appending the message.

	Inputs:
	- p_actor:   A pointer to the actor receiving the message.
	- from:      The ActorRef of the sender (the actor who is sending the message).
	- content:   The content of the message being received.
*/
actor_receive_message :: proc( p_actor: ^Actor, from: ActorRef, content: MessageContent )
{
    switch p_actor.life_state
	{
    case .Running, .Stopping, .Restarting:
        append(&p_actor.mailbox, Message{ from = from, content = content })
        fmt.printfln( "Actor %d received a message from actor %d.", p_actor.ref, from )

    case .Stopped:
        fmt.printfln( "Actor %d is stopped and cannot receive messages.", p_actor.ref )

    case .Terminated:
        fmt.printfln( "Actor %d is terminated and cannot receive messages.", p_actor.ref )

    case .Initialized:
        fmt.printfln( "Actor %d is initialized but not yet running, cannot receive messages.", p_actor.ref )
    }
}

/*
	actor_terminate is responsible for terminating an actor and transitioning it to the `Terminated` state.
	Once terminated, the actor's mailbox is cleared, and it will no longer process any messages.

	Inputs:
	- p_actor: A pointer to the actor that is to be terminated.
*/
actor_terminate :: proc( p_actor: ^Actor )
{
    if p_actor.life_state == .Terminated
	{
        fmt.printfln( "Actor %d is already terminated.", p_actor.ref )
        return
    }

    fmt.printfln( "Terminating actor %d...", p_actor.ref )
    p_actor.life_state = .Terminated

    clear( &p_actor.mailbox )

    // Log the successful termination
    fmt.printfln( "Actor %d has been terminated.", p_actor.ref )
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