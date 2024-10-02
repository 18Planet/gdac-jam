using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleEntityStateMachine : StateMachine
{    
    protected InputData inputData;
    public InputData InputData => inputData;

    protected MovementPhysicsScript movementPhysics;
    public MovementPhysicsScript MovementPhysics => movementPhysics;

    protected AnimationManager animator;
    public AnimationManager Animator => animator;

    protected BasicEntity entity;
    public BasicEntity Entity => entity;

    public void InitializeStateMachine(State initialState, BasicEntity entity, AnimationManager animator, InputData inputData, MovementPhysicsScript movementPhysics)
    {
        this.entity = entity;
        this.inputData = inputData;
        this.movementPhysics = movementPhysics;
        this.animator = animator;

        // Enter initial state
        currentState = initialState;
        currentState.EnterState();
    }

    public override void SetCurrentState(State state)
    {
        currentState = state;
    }

    public void ForceSwitchState(State state)
    {
        if(currentState.GetType() != state.GetType())
            currentState.SwitchState(state);
    }
}
