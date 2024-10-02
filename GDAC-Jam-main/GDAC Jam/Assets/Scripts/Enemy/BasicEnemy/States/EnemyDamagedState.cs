using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDamagedState : EnemyState
{
    public EnemyDamagedState(SimpleEntityStateMachine context, AttackData data) : base(context) 
    {
        attackData = data;
    }

    private AttackData attackData;

    private float timer = 0f;

    public override bool CheckSwitchState()
    {
        if(timer < 0f)
        {
            SwitchState(new EnemyIdleState(context));
            return true;
        }
        return false;
    }
    public override void EnterState()
    {
        base.EnterState();
        context.MovementPhysics.StopMovement();
        context.Animator.SetAnimation("Damaged", true);
        context.Animator.ForceUpdate();
        context.Animator.SetFlipDirection(-attackData.knockbackDirection.x);
        timer = context.Animator.GetCurrentStateDuration();
        context.MovementPhysics.RbVel = attackData.knockbackDirection.normalized * attackData.knockbackVelocity;
        // do nothing
    }

    public override void ExitState()
    {
        base.ExitState();
        // do nothing
    }

    public override void FixedUpdateState()
    {
        context.MovementPhysics.ApplyFixedFriction();
    }

    public override void UpdateState()
    {
        CheckSwitchState();
        timer -= Time.deltaTime;
    }
}
