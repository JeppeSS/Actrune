package actrune

/*
	ActorRef is a distinct type that represents a unique reference to an actor.
*/
ActorRef :: distinct u32

/*
	Actor is the core structure representing an actor in the system.

	Fields:
	- ref: A unique reference (ActorRef) to this actor.
	- p_state: A raw pointer to the actor's internal state. This allows flexibility 
	           for actors to manage different kinds of data as their state.
*/
Actor :: struct
{
    ref:       ActorRef,
    p_state:   rawptr
}