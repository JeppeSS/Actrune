package main

import "core:fmt"
import "core:log"
import ar "actrune:actor"


Room_State :: struct
{
    users: map[ string ]ar.ActorRef
}

Join_Message :: struct
{
    username: string
}


Leave_Message :: struct
{
    username: string
}

Chat_Message :: struct
{
    from:    string,
    message: string
}




room_behavior :: proc( p_actor_system: ^ar.ActorSystem, p_room_actor: ^ar.Actor, message: ar.Message )
{
    state := cast(^Room_State)p_room_actor.state.(rawptr)
    if message.header.type == "Join_Message"
    {
        join_message := cast(^Join_Message)message.content.(rawptr)
        fmt.printfln("USER %s joined", join_message.username)

        broadcast_message := fmt.aprintf("User %s joined", join_message.username)
        broadcast( p_actor_system, p_room_actor, broadcast_message )

        state.users[ join_message.username ] = message.header.from
    }
    else if message.header.type == "Leave_Message"
    {
        leave_message := cast(^Leave_Message)message.content.(rawptr)
        fmt.printfln("USER %s leaved", leave_message.username)

        delete_key( &state.users, leave_message.username )

        broadcast_message := fmt.aprintf("User %s leaved", leave_message.username)
        broadcast( p_actor_system, p_room_actor, broadcast_message )
    }
}


broadcast :: proc( p_actor_system: ^ar.ActorSystem, p_room_actor: ^ar.Actor, message: string)
{
    state := cast(^Room_State)p_room_actor.state.(rawptr)
    for _, ref in state.users
    {
        p_chat_message := new( Chat_Message )
        p_chat_message.from = "SYSTEM"
        p_chat_message.message = message
        ar.actor_system_tell( p_actor_system, p_room_actor.ref, ref, ar.Message_Payload{ type = "Chat_Message", content = rawptr( p_chat_message ) } )
    }
}

user_behavior :: proc( p_actor_system: ^ar.ActorSystem, p_user_actor: ^ar.Actor, message: ar.Message )
{
    if message.header.type == "Chat_Message"
    {
        chat_message := cast(^Chat_Message)message.content.(rawptr)
        fmt.printfln("[%s] %s", chat_message.from, chat_message.message )
        delete(chat_message.message)
        free(chat_message)
    }
}


room_state_create :: proc() -> ^Room_State
{
    p_room_state := new( Room_State )
    p_room_state.users = make( map[ string ]ar.ActorRef )
    return p_room_state
}

room_state_destroy :: proc( p_room_state: ^Room_State )
{
    delete( p_room_state.users )
    free( p_room_state )
}




main :: proc()
{
    context.logger = log.create_console_logger(lowest = log.Level.Info, opt = log.Options{.Level, .Terminal_Color} | log.Full_Timestamp_Opts)

    p_actor_system := ar.actor_system_create("Hagall Chat")
    defer ar.actor_system_terminate( p_actor_system )

    p_room_state := room_state_create()
    defer room_state_destroy( p_room_state )

    room_ref := ar.actor_system_spawn( p_actor_system, room_behavior,  rawptr( p_room_state )  )
    user_ref := ar.actor_system_spawn( p_actor_system, user_behavior, nil )

    {
        join_message := Join_Message{ username = "test" }
        ar.actor_system_tell( p_actor_system, user_ref, room_ref, ar.Message_Payload{ type = "Join_Message", content = rawptr( &join_message ) } )
    }

    for i := 0; i < 10; i += 1
    {
        ar.actor_system_process_messages( p_actor_system )

        if i == 3
        {
            join_message := Join_Message{ username = "abc" }
            ar.actor_system_tell( p_actor_system, user_ref, room_ref, ar.Message_Payload{ type = "Join_Message", content = rawptr( &join_message ) } )
        }


        if i == 5
        {
            leave_message := Leave_Message{ username = "test" }
            ar.actor_system_tell( p_actor_system, user_ref, room_ref, ar.Message_Payload{ type = "Leave_Message", content = rawptr( &leave_message ) } )
        }



    }
}