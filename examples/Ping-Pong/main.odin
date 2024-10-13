package main

import "core:fmt"
import ar "actrune:actor"

ping_pong_behavior :: proc( p_actor: ^ar.Actor, message: ar.Message )
{
    if message.content.(string) == "ping"
    {
        fmt.printfln( "Received Ping, sending Pong" )
        p_actor.state = p_actor.state.(int) + 1
        if p_actor.state.(int) != 5
        {
            ar.actor_send_message( p_actor, message.from, ar.Message{ from = p_actor, content = "pong" } )
        }
    }
    else
    {
        fmt.printfln( "Received Pong, sending Ping" )
        p_actor.state = p_actor.state.(int) + 1
        if p_actor.state.(int) != 5
        {
            ar.actor_send_message( p_actor, message.from, ar.Message{ content = "ping" } )
        }
    }
}

main :: proc()
{
    ping_actor := ar.Actor{
        ref = 1,
        behavior = ping_pong_behavior,
        state = 0
    };
    pong_actor := ar.Actor{
        ref = 2,
        behavior = ping_pong_behavior,
        state = 0
    };

    ar.actor_send_message( &ping_actor, &pong_actor, ar.Message{ content="ping" } );
}