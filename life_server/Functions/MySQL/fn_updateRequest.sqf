/*
    File: fn_updateRequest.sqf
    Author: Bryan "Tonic" Boardwine
    Description:
    Updates ALL player information in the database.
    Information gets passed here from the client side file: core\session\fn_updateRequest.sqf
*/
params [
  ["_uid","",[""]],
  ["_name","",[""]],
  ["_side",sideUnknown,[civilian]],
  ["_cash",0,[0]],
  ["_bank",5000,[0]],
  ["_licenses",[],[[]]],
  ["_gear",[],[[]]],
  ["_stats",[100,100],[[]]],
  "",
  "",
  ["_position",[],[[]]]
];

//Get to those error checks.
if (_uid isEqualTo "" || {_name isEqualTo ""}) exitWith {};

//Parse and setup some data.
_name = [_name] call DB_fnc_mresString;
_gear = [_gear] call DB_fnc_mresArray;
_stats = [_stats] call DB_fnc_mresArray;
_cash = [_cash] call DB_fnc_numberSafe;
_bank = [_bank] call DB_fnc_numberSafe;
_position = if (_side isEqualTo civilian) then {[_position] call DB_fnc_mresArray} else {[]};

//Does something license related but I can't remember I only know it's important?
for "_i" from 0 to count(_licenses)-1 do {
    private _bool = [(_licenses select _i) select 1] call DB_fnc_bool;
    _licenses set[_i,[(_licenses select _i) select 0,_bool]];
};

_licenses = [_licenses] call DB_fnc_mresArray;

//PLAYTIME
private _playtime = [_uid] call TON_fnc_getPlayTime;
private _playtime_update = [];
{
    if ((_x select 0) isEqualTo _uid) exitWith
    {
        _playtime_update pushBack [_x select 1];
    };
} forEach TON_fnc_playtime_values_request;
_playtime_update = (_playtime_update select 0) select 0;
switch (_side) do {
    case west: {_playtime_update set[0,_playtime];};
    case civilian: {_playtime_update set[2,_playtime];};
    case independent: {_playtime_update set[1,_playtime];};
};
_playtime_update = [_playtime_update] call DB_fnc_mresArray;

private "_query";
switch (_side) do {
    case west: {_query = format["UPDATE players SET name='%1', cash='%2', bankacc='%3', cop_gear='%4', cop_licenses='%5', cop_stats='%6', playtime='%7' WHERE playerid='%8'",_name,_cash,_bank,_gear,_licenses,_stats,_playtime_update,_uid];};
    case civilian: {_query = format["UPDATE players SET name='%1', cash='%2', bankacc='%3', civ_licenses='%4', civ_gear='%5', arrested='%6', civ_stats='%7', civ_alive='%8', civ_position='%9', playtime='%10' WHERE playerid='%11'",_name,_cash,_bank,_licenses,_gear,[_this select 8] call DB_fnc_bool,_stats,[_this select 9] call DB_fnc_bool,_position,_playtime_update,_uid];};
    case independent: {_query = format["UPDATE players SET name='%1', cash='%2', bankacc='%3', med_licenses='%4', med_gear='%5', med_stats='%6', playtime='%7' WHERE playerid='%8'",_name,_cash,_bank,_licenses,_gear,_stats,_playtime_update,_uid];};
};


_queryResult = [_query,1] call DB_fnc_asyncCall;
