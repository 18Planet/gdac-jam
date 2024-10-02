using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class PlayerState : SimpleEntityState
{
    protected PlayerState(SimpleEntityStateMachine context) : base(context) { }

    public override void EnterState()
    {
        context.Entity.OnDamageReceived += OnDamaged;
    }

    public override void ExitState()
    {
        context.Entity.OnDamageReceived -= OnDamaged;
    }

    protected virtual void OnDamaged(AttackData attackData, float currentHealth)
    {
        CameraShake.instance.CreateImpulse(0.5f, 0.4f);
        if(currentHealth <= 0)
            SwitchState(new PlayerDeadState(context, attackData));
        else
            SwitchState(new PlayerDamagedState(context, attackData));
    }
}
