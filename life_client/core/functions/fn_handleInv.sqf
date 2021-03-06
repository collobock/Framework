#include "..\..\script_macros.hpp"
/*
    File: fn_handleInv.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Do I really need one?
*/
private["_math","_item","_num","_return","_var","_weight","_value","_diff"];
params [
  ["_math",false,[false]],
  ["_item","",[""]],
  ["_num",0,[0]]
];
if (_item isEqualTo "" || _num isEqualTo 0) exitWith {false};

_var = ITEM_VARNAME(_item);

if (_math) then {
    _diff = [_item,_num,life_carryWeight,life_maxWeight] call life_fnc_calWeightDiff;
    _num = _diff;
    if (_num <= 0) exitWith {false};
};
_weight = ([_item] call life_fnc_itemWeight) * _num;
_value = ITEM_VALUE(_item);

if (_math) then {
    //Lets add!
    if ((life_carryWeight + _weight) <= life_maxWeight) then {
        missionNamespace setVariable [_var,(_value + _num)];

        if ((missionNamespace getVariable _var) > _value) then {
            life_carryWeight = life_carryWeight + _weight;
            _return = true;
        } else {
            _return = false;
        };
    } else {_return = false;};
} else {
    //Lets SUB!
    if ((_value - _num) < 0) then { _return = false;} else {
        missionNamespace setVariable [_var,(_value - _num)];

        if ((missionNamespace getVariable _var) < _value) then {
            life_carryWeight = life_carryWeight - _weight;
            _return = true;
        } else {_return = false;};
    };
};

_return;
