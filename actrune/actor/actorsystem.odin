package actor

import "core:fmt"

/*
	ActorSystem is a structure that manages a collection of actors in the system.
	It serves as the central point for spawning actors, sending messages, and processing those messages.
	Each ActorSystem maintains a map of ActorRefs to their corresponding Actor pointers, ensuring unique identification of each actor.

	Fields:
	- name:     A string representing the name of the actor system.
	- p_actors: A map where each ActorRef (unique reference) is associated with a pointer to its corresponding Actor.
*/
ActorSystem :: struct
{
    name:     string,
    p_actors: map[ ActorRef ]^Actor
}

/*
	actor_system_create initializes a new ActorSystem with the given name.
	It allocates memory for the ActorSystem structure, sets its name, and creates an empty map to hold actors.

	Inputs:
	- name: The name of the actor system.

	Returns:
	- A pointer to the newly created ActorSystem.
*/
actor_system_create :: proc( name: string ) -> ^ActorSystem
{
    p_actor_system := new( ActorSystem )
    p_actor_system.name = name
    p_actor_system.p_actors = make( map[ ActorRef ]^Actor )
    return p_actor_system
}

/*
	actor_system_spawn creates a new actor within the ActorSystem.
	It assigns the actor a unique ActorRef, initializes its state and behavior, and adds it to the actor system's map.

	Inputs:
	- p_actor_system: A pointer to the ActorSystem in which the actor is to be created.
	- behavior:       The behavior function that defines how the actor processes messages.
	- state:          The initial state of the actor..

	Returns:
	- ActorRef: A unique reference to the newly created actor, which can be used to send messages to it.
*/
actor_system_spawn :: proc( p_actor_system: ^ActorSystem, behavior: Behavior, state: ActorState ) -> ActorRef
{
    p_actor := new( Actor )
    p_actor.ref = ActorRef( len( p_actor_system.p_actors ) )
    p_actor.mailbox = make( [dynamic]Message )
    p_actor.behavior = behavior
    p_actor.state = state

    p_actor_system.p_actors[ p_actor.ref ] = p_actor

    return p_actor.ref
}

/*
	actor_system_tell sends a message from one actor to another within the ActorSystem.
	If the destination actor exists, the message is added to its mailbox.

	Inputs:
	- p_actor_system: A pointer to the ActorSystem containing the actors.
	- from:           The ActorRef of the sender, which will be included in the message for the recipient to know the sender.
	- to:             The ActorRef of the recipient actor to which the message is being sent.
	- message:        The content of the message being sent.
*/
actor_system_tell :: proc( p_actor_system: ^ActorSystem, from: ActorRef, to: ActorRef, message: MessageContent )
{
    p_to_actor, ok := p_actor_system.p_actors[ to ]
    if ok
    {
        append( &p_to_actor.mailbox, Message{ from = from, content = message } )
    }
    else
    {
        fmt.printfln( "Could not find actor: %d", to ) // TODO[Jeppe]: Handle this case
    }
}

/*
	actor_system_process_messages processes all messages for each actor in the ActorSystem.
	For each actor, it retrieves the next message from the actor’s mailbox (if available) and invokes the actor's behavior function to handle it.

	Inputs:
	- p_actor_system: A pointer to the ActorSystem managing the actors.
*/
actor_system_process_messages :: proc( p_actor_system: ^ActorSystem )
{
    for ref in p_actor_system.p_actors
    {
        p_actor := p_actor_system.p_actors[ ref ]
        message, ok := pop_front_safe( &p_actor.mailbox )
        if ok
        {
            p_actor.behavior( p_actor_system, p_actor, message )
        }
    }
}

/*
	actor_system_destroy deallocates and cleans up the ActorSystem and all the actors it contains.
	It iterates through all actors, destroys each one (by deallocating their resources), and then deletes the actor map and the ActorSystem itself.

	Inputs:
	- p_actor_system: A pointer to the ActorSystem that is to be destroyed.
*/
actor_system_destroy :: proc( p_actor_system: ^ActorSystem )
{
    for ref in p_actor_system.p_actors
    {
        p_actor := p_actor_system.p_actors[ ref ]
        actor_destroy( p_actor )
    }
    delete( p_actor_system.p_actors )
    free( p_actor_system )
}