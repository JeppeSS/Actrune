package main

import "core:fmt"
import "core:log"
import ar "actrune:actor"

ping_pong_behavior :: proc( p_actor_system: ^ar.ActorSystem, p_actor: ^ar.Actor, message: ar.Message )
{
    if message.header.type == "ping"
    {
        fmt.printfln( "Received Ping, sending Pong" )
        p_actor.state = p_actor.state.(int) + 1
        if p_actor.state.(int) != 5
        {
            ar.actor_system_tell( p_actor_system, p_actor.ref, message.header.from, ar.Message_Payload{ type = "pong" } )
        }
    }
    else
    {
        fmt.printfln( "Received Pong, sending Ping" )
        p_actor.state = p_actor.state.(int) + 1
        if p_actor.state.(int) != 5
        {
            ar.actor_system_tell( p_actor_system, p_actor.ref, message.header.from, ar.Message_Payload{ type = "ping" } )
        }
    }
}

main :: proc()
{
    context.logger = log.create_console_logger(opt = log.Options{.Level, .Terminal_Color} | log.Full_Timestamp_Opts)

    p_actor_system := ar.actor_system_create("Ping Pong")
    defer ar.actor_system_terminate( p_actor_system )


    ping_actor_ref := ar.actor_system_spawn( p_actor_system, ping_pong_behavior, 0 )
    pong_actor_ref := ar.actor_system_spawn( p_actor_system, ping_pong_behavior, 0 )

    ar.actor_system_tell( p_actor_system, ping_actor_ref, pong_actor_ref, ar.Message_Payload{ type = "ping" } )

    for i := 0; i < 10; i += 1
    {
        ar.actor_system_process_messages( p_actor_system )
    }
}