using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SimpleEntityState : State
{
    protected SimpleEntityStateMachine context;

    public SimpleEntityState(SimpleEntityStateMachine context)
    {
        this.context = context;
    }
    public abstract bool CheckSwitchState();
    public abstract void EnterState();
    public abstract void ExitState();
    public abstract void FixedUpdateState();
    public virtual void SwitchState(State state)
    {
        ExitState();
        context.SetCurrentState(state);
        state.EnterState();
    }
    public abstract void UpdateState();
}
