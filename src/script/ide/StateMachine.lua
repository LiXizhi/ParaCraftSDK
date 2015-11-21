--[[
Title: Finite State Machine(FSM) implemented in NPL
Author(s): WangTian
Date: 2008/1/3
Desc: A Finite State Machine(FSM) or finite state automaton (plural: automata) or simply a state machine, 
		is a model of behavior composed of a finite number of states, transitions between those states, and actions. 
		A finite state machine is an abstract model of a machine with a primitive internal memory.
		
A current state is determined by past states of the system. As such, it can be said to record information about the past, 
i.e. it reflects the input changes from the system start to the present moment. A transition indicates a state change 
and is described by a condition that would need to be fulfilled to enable the transition. 

An action is a description of an activity that is to be performed at a given moment. There are several action types:
	Entry action		which is performed when entering the state 
	Exit action			which is performed when exiting the state 
	Input action		which is performed depending on present state and input conditions 
	Transition action	which is performed when performing a certain transition 

Here we only define the Deterministic Finite State Machine(DFSM), which is a quintuple (¦²,S,s0,¦Ä,F) where:
	¦² is the input alphabet (a finite, non-empty set of symbols). 
	S is a finite, non-empty set of states. 
	s0 is an initial state, an element of S. 
	¦Ä is the state-transition function: ¦Ä:S X ¦² -> S.
	F is the set of final states, a (possibly empty) subset of S. 

Inputs: ¦², index and string pair
States: S, index and string pair + 4 actions
Transitions: ¦Ä, Current state index, input index, next state index
Start: s0, state index
Finals: F, state indices

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/StateMachine.lua");
-------------------------------------------------------
]]

local StateMachine = {};
if(not commonlib.StateMachine) then commonlib.StateMachine = StateMachine; end

-- create a state machine
function StateMachine:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self);
	self.__index = self;
	
	o.Inputs = {};
	o.States = {};
	o.Transitions = {};
	o.start = nil;
	o.Finals = {};
	
	o.InputActions = {};
	o.TransitionActions = {};
	o.currentState = nil;
	
	return o;
end

-- Destroy the state machine
function StateMachine:Destroy()
end

---------------------------------
-- FSM data init
---------------------------------

-- append input alphabet entry
-- @param index: input alphabet index
-- @param desc: string value to clarify input content
-- e.g. if used in NPC dialog, it could be the dialog text
-- e.g. if used in AI module, it could be the transition condition description
-- we strongly recommend this desc value is unique as the index, since we allow transition using this string value as an input
function StateMachine:AppendInput(index, desc)
	self.Inputs[index] = desc;
end

function StateMachine:ClearInputs()
	self.Inputs = {};
end

-- append state
-- @param index: state index
-- @param desc: string value to clarify state
-- e.g. if used in NPC dialog, it could be the state description
-- e.g. if used in AI module, it could be particular mental state
function StateMachine:AppendState(index, desc)
	self.States[index] = {desc = desc};
end

-- replace the previous state with the new one
function StateMachine:ModifyState(index, desc)
	local _, state;
	for _, state in pairs(self.States) do
		if(_ == index) then
			self.States[_].desc = desc;
			return;
		end
	end
	-- if the state is not appended before, append a new one
	self:AppendState(index, desc);
end

-- append transition
-- @param current_index: current state index
-- @param input_index: input index
-- @param next_index: next state index
-- e.g if current state index is current_index, on input condition input_index, the next state index is next_index
function StateMachine:AppendTransition(current_index, input_index, next_index)
	table.insert(self.Transitions, {
		current = current_index, 
		input = input_index, 
		next = next_index
	});
end

-- replace the previous transition with the new one
function StateMachine:ModifyTransition(current_index, input_index, next_index)
	local _, transition;
	for _, transition in pairs(self.Transitions) do
		if(transition.current == current_index and transition.input == input_index) then
			self.Transitions[_].next = next_index;
			return;
		end
	end
	-- if the transition is not appended before, append a new one
	self:AppendTransition(current_index, input_index, next_index);
end

-- set start state
-- @param index: start state index
function StateMachine:SetStartState(index)
	local state = self.States[index];
	if(state == nil) then
		log("error: SetStartState call before state is inited \n")
		return;
	end
	self.start = index;
end

-- set start state
-- @param indices: final state indices
-- e.g. {2, 8, 19}
function StateMachine:SetFinalStates(indices)
	self.Finals = commonlib.deepcopy(indices);
end

-- NOTE: the following SetState*******Action functions must be called AFTER the state/input/transition is appended

-- NOTE: we don't call Entry action of start state and Exit action of final states when state machine Runs and Finishes

-- set entry action that performed when entering the state
-- @param index: state index
-- @param action: if string value, commandname or DoString, 
--		if function value, call function with state index as parameter: function(index)
-- @param params: the parameters passed to the app command
function StateMachine:SetStateEntryAction(index, action, params)
	local state = self.States[index];
	if(state == nil) then
		log("error: SetStateEntryAction call before state is inited \n")
		return;
	end
	self.States[index].EntryAction = {
			action = action,
			params = params,
		};
end

-- set entry action that performed when exiting the state
-- @param index: state index
-- @param action: if string value, commandname or DoString, 
--		if function value, call function with state index as parameter: function(index)
-- @param params: the parameters passed to the app command
function StateMachine:SetStateExitAction(index, action, params)
	local state = self.States[index];
	if(state == nil) then
		log("error: SetStateExitAction call before state is inited \n")
		return;
	end
	self.States[index].ExitAction = {
			action = action,
			params = params,
		};
end

-- set entry action that performed depending on present state and input 
-- @param index: present state index
-- @param inputindex: input index
-- @param action: if string value, commandname or DoString, 
--		if function value, call function with state index as parameter: function(index)
-- @param params: the parameters passed to the app command
function StateMachine:SetStateInputAction(index, inputindex, action, params)
	local state = self.States[index];
	if(state == nil) then
		log("error: SetStateInputAction call before state is inited \n")
		return;
	end
	self.InputActions = {
			index = index, 
			inputindex = inputindex, 
			action = action,
			params = params,
		};
end

-- set entry action that performed when performing a certain transition(from fromindex to toindex)
-- @param fromindex: transition from fromindex to toindex
-- @param toindex: transition from fromindex to toindex
-- @param action: if string value, commandname or DoString, 
--		if function value, call function with state index as parameter: function(index)
-- @param params: the parameters passed to the app command
function StateMachine:SetStateTransitionAction(fromindex, toindex, action, params)
	local state = self.States[fromindex];
	if(state == nil) then
		log("error: SetStateTransitionAction call before state/transition is inited \n")
		return;
	end
	local state = self.States[toindex];
	if(state == nil) then
		log("error: SetStateTransitionAction call before state/transition is inited \n")
		return;
	end
	self.TransitionActions = {
			fromindex = fromindex, 
			toindex = toindex, 
			action = action,
			params = params,
		};
end

-- set final callback
-- this callback function is called when the state machine reach its final states,
-- call function with state index as parameter: function(finalindex)
function StateMachine:SetFinalCallback(callback)
	self.FinalCallBack = callback;
end

-- get accepted inputs according to state index
-- @param index: state index. if the index is nil, the current state is used
function StateMachine:GetAcceptInputs(index)
	if(index == nil) then
		index = self.currentState;
		if(index == nil) then
			return;
		end
	end
	local inputs = {};
	for _, transition in pairs(self.Transitions) do
		if(transition.current == index) then
			local __, input;
			local bExist = false;
			for __, input in pairs(inputs) do
				if(transition.input == input) then
					bExist = true;
					break;
				end
			end
			if(bExist == false) then
				table.insert(inputs, transition.input);
			end
		end
	end
	return inputs;
end

---------------------------------
-- FSM public functions
---------------------------------

-- run the state machine from the initial state
function StateMachine:Run()
	self.currentState = self.start;
	-- call entry action
	self:DoAction(self.States[self.currentState].EntryAction);
end

-- get current state
function StateMachine:GetCurrentState()
	return self.currentState;
end

-- assign the state machine with input
-- state machine will run by itself with state switching, and call approporate actions 
function StateMachine:Input(index)
	if(self.currentState == nil) then
		log("error: the state machine is not started on Input() call \n")
		return;
	end
	local currentState = self.currentState;
	local transition;
	for _, transition in pairs(self.Transitions) do
		if(transition.current == currentState) and (transition.input == index) then
			local nextState = transition.next;
			
			-- NOTE: if multiple actions are available, call the actions according to the following sequence:
			--		Entry action		which is performed when entering the state 
			--		Exit action			which is performed when exiting the state 
			--		Input action		which is performed depending on present state and input conditions 
			--		Transition action	which is performed when performing a certain transition 
			
			self:DoAction(self.States[nextState].EntryAction);
			self:DoAction(self.States[currentState].ExitAction);
			
			local inputAction;
			for _, inputAction in pairs(self.InputActions) do
				if(inputAction.index == currentState and inputAction.inputindex == index) then
					self:DoAction(inputAction);
					break;
				end
			end
			local transitionAction;
			for _, transitionAction in pairs(self.TransitionActions) do
				if(transitionAction.fromindex == currentState and transitionAction.toindex == nextState) then
					self:DoAction(transitionAction);
					break;
				end
			end
			
			local final;
			for _, final in pairs(self.Finals) do
				if(nextState == final) then
					-- call FinalCallBack
					if(type(self.FinalCallBack) == "function") then
						self.FinalCallBack(final);
					end
					-- state machine reach its final states
					self.currentState = nil;
					return;
				end
			end
			-- set new state
			self.currentState = nextState;
			return;
		end
	end
end

-- force the state machine to terminate
-- NOTE: the state machine usually terminates by itself, this function is a public method for user to force terminate
-- NOTE: check for better logic whether to call the exit actions, currently we call the exit action of the current state
-- since there might be multiple final states, we don't call any entry actions of final states
-- we strongly recommend to terminate the state machine with inputs
function StateMachine:Terminate()
	if(currentState ~= nil) then
		self:DoAction(self.States[currentState].ExitAction);
		self.currentState = nil;
	end
end

-- do action 
-- @param actionTable: action parameter table
-- e.g. {action = ..., params = ...}
function StateMachine:DoAction(actionTable)
	if(actionTable == nil) then
		return;
	end
	local action = actionTable.action;
	local params = actionTable.params;
	if(type(action) == "string") then
		-- first check if the action is a commandname
		local command = System.App.Commands.GetCommand(action);
		if(command ~= nil) then
			-- call command
			command:Call(params);
		else
			-- do string
			NPL.DoString(action);
		end
	elseif(type(action) == "function") then
		-- call function
		action(self.currentState);
	end
end