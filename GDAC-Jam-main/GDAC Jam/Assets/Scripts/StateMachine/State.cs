using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface State
{
    public void EnterState();
    public void ExitState();
    public void SwitchState(State state);
    /// <summary>
    /// Should return true if switched to new state, false otherwise
    /// </summary>
    /// <returns></returns>
    public bool CheckSwitchState();
    public void UpdateState();
    public void FixedUpdateState();
}
