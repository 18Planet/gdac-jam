using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class EnemyState : SimpleEntityState
{
    protected EnemyState(SimpleEntityStateMachine context) : base(context) { }

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
        if (currentHealth <= 0)
            SwitchState(new EnemyDeadState(context, attackData));
        else
            SwitchState(new EnemyDamagedState(context, attackData));
    }
}
