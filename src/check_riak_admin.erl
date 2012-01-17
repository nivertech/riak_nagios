-module(check_riak_admin).

-export([main/1]).
%%%%%%
%
% This is a check based on the output of riak-admin status
%
% Available checks are documented in usage/0


get_property(Prop, Strings) ->
    riak_nagios:get_property(Prop, Strings, 3).

main([Property, Warn, Critical]) ->
    WarnThreshold = riak_nagios:value(Warn),
    CriticalThreshold = riak_nagios:value(Critical),
    
    Status = string:tokens(os:cmd("riak-admin status"), "\n"),
    case Property of
        "memory" -> riak_nagios:decide(
            "Memory", 
            get_property("mem_allocated", Status) / get_property("mem_total", Status), 
            WarnThreshold, 
            CriticalThreshold);
        "siblings" -> riak_nagios:decide(
            "Siblings", 
            get_property("node_get_fsm_siblings_mean", Status), 
            WarnThreshold, 
            CriticalThreshold)
        %% TODO: Tx/Rx within the cluster (GET/PUT fsms)
    end;
main(_) ->
    usage().

usage() ->
    io:format("Usage: check_riak_admin.erl property warning-threshold critical-threshold~n"),
    io:format("property~n"),
    io:format("    memory   - percent of memory allocated to riak~n"),
    io:format("    siblings - Mean number of siblings encountered of all GETs by this node within the last minute~n"),
    io:format("warning-threshold  - If the check returns a value above this, return a nagios warning~n"),
    io:format("critical-threshold - If the check returns a value above this, return a nagios critical~n"),
    riak_nagios:unknown("improper usage of check script").