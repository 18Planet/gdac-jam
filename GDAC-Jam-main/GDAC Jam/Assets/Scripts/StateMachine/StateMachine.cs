using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class StateMachine : MonoBehaviour
{
    protected State currentState;

    public abstract void SetCurrentState(State state);

    protected void Update()
    {
        currentState.UpdateState();
    }

    protected void FixedUpdate()
    {
        currentState.FixedUpdateState();
    }

}
