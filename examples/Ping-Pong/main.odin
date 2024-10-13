package main

import "core:fmt"
import ar "actrune:actor"

message_handler :: proc( p_from_actor: ^ar.Actor, p_to_actor: ^ar.Actor, message: ar.Message )
{
    if message.content.(string) == "ping"
    {
        fmt.printfln( "Received Ping, sending Pong" )
        p_to_actor.state = p_to_actor.state.(int) + 1
        if p_to_actor.state.(int) != 5
        {
            ar.actor_send_message( p_to_actor, p_from_actor, ar.Message{ content = "pong" } )
        }
    }
    else
    {
        fmt.printfln( "Received Pong, sending Ping" )
        p_to_actor.state = p_to_actor.state.(int) + 1
        if p_to_actor.state.(int) != 5
        {
            ar.actor_send_message( p_to_actor, p_from_actor, ar.Message{ content = "ping" } )
        }
    }
}

main :: proc()
{
    ping_actor := ar.Actor{
        ref = 1,
        handler = message_handler,
        state = 0
    };
    pong_actor := ar.Actor{
        ref = 2,
        handler = message_handler,
        state = 0
    };

    ar.actor_send_message( &ping_actor, &pong_actor, ar.Message{ content="ping" } );
}