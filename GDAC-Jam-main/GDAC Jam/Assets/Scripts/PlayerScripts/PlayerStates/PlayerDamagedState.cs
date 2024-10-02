using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDamagedState : PlayerState
{
    public PlayerDamagedState(SimpleEntityStateMachine context, AttackData data) : base(context) 
    {
        attackData = data;
    }

    private AttackData attackData;

    private float timer = 0f;

    public override bool CheckSwitchState()
    {
        if(timer < 0f)
        {
            SwitchState(new PlayerIdleState(context));
            return true;
        }
        return false;
    }

    protected override void OnDamaged(AttackData data, float currentHealth)
    {
        // do nothing
    }

    public override void EnterState()
    {
        base.EnterState();
        context.MovementPhysics.StopMovement();
        context.Animator.SetAnimation("Damaged");
        context.Animator.ForceUpdate();
        context.Animator.SetFlipDirection(-attackData.knockbackDirection.x);
        timer = context.Animator.GetCurrentStateDuration();
        context.MovementPhysics.RbVel = attackData.knockbackDirection.normalized * attackData.knockbackVelocity;
        // do nothing
    }

    public override void ExitState()
    {
        context.Animator.SetAnimation("Idle");
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
