package actor

import "core:log"

/*
	Supervision_Strategy is an enum that defines the different strategies a supervisor can apply
	when one of its child actors encounters an error or failure. The strategy determines how the
	supervisor should handle the failure and what action should be taken for the affected child actor.
*/
Supervision_Strategy :: enum u8
{
	Restart  = 0, // Restart the child actor
	Stop     = 1, // Stop the child actor
	Resume   = 2, // Resume the child actor without restarting
	Escalate = 3  // Escalate the failure to a higher-level supervisor
}

/*
	Supervisor_Error_Message is a structure that is sent to a supervisor when one of its child actors encounters an error.
	It contains information about the child actor that failed and the supervision strategy that should be applied to handle the failure.

	Fields:
	- child_actor_ref: The ActorRef of the child actor that encountered the error.
	- strategy:        The Supervision_Strategy that the supervisor should apply (e.g., Restart, Stop, Resume, or Escalate).
*/
Supervisor_Error_Message :: struct
{
    child_actor_ref: ActorRef,
    strategy:        Supervision_Strategy
}

/*
	supervisor_behavior is the behavior function for a supervisor actor.
	It handles error messages from its child actors and applies the appropriate supervision strategy to manage the error.
	When a child actor encounters a failure, it sends a Supervisor_Error_Message to its supervisor, which then decides
	whether to restart, stop, resume, or escalate the error based on the provided strategy.

	Inputs:
	- p_actor_system: A pointer to the ActorSystem that manages the actors.
	- p_supervisor_actor: A pointer to the supervisor actor receiving the error message.
	- message: The Message containing the Supervisor_Error_Message, which specifies the child actor and the strategy to apply.
*/
supervisor_behavior :: proc( p_actor_system: ^ActorSystem, p_supervisor_actor: ^Actor, message: Message )
{
    if message.header.type == "Supervisor_Error_Message"
    {
        error_message := cast(^Supervisor_Error_Message)message.content.(rawptr)
        child_ref     := error_message.child_actor_ref
        strategy      := error_message.strategy

        switch strategy
        {
            case .Restart:
            {
                log.debugf( "Restarting child actor %d...", child_ref )
                actor_restart( p_actor_system.p_actors[ child_ref ] ) // TODO[Jeppe]: Handle potential invalid ref
            }

            case .Stop:
            {
                log.debugf( "Stopping child actor %d...", child_ref )
                actor_immediate_stop( p_actor_system.p_actors[ child_ref ] ) // TODO[Jeppe]: Handle potential invalid ref
            }

            case .Resume:
            {
                log.debugf( "Resuming child actor %d without restarting...", child_ref )
            }

            case .Escalate:
            {
                log.debugf( "Escalating failure from child actor %d", child_ref )
                // TODO[Jeppe]: Figure out how escalating to higher-level supervisor should be done
            }
        }
    }
}