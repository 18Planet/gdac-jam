using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyIdleState : EnemyState
{

    public EnemyIdleState(SimpleEntityStateMachine context) : base(context) { }


    public override bool CheckSwitchState()
    {
        if(context.InputData.MovementInput != Vector2.zero)
        {
            SwitchState(new EnemyRunState(context));
            return true;
        }
        return false;
    }

    public override void EnterState()
    {
        base.EnterState();
    }

    public override void ExitState()
    {
        base.ExitState();
        context.Animator.SetSpeed(1);
    }

    public override void FixedUpdateState()
    {
        context.MovementPhysics.ApplyFixedFriction();
    }

    public override void UpdateState()
    {
        if (CheckSwitchState()) 
            return;
        float currentVel = context.MovementPhysics.RbVel.magnitude;
        bool isStill = currentVel < 0.1f;
        if (isStill)
        {
            context.Animator.SetSpeed(1);
            context.Animator.SetAnimation("Idle");
        }
        else
        {
            context.Animator.SetSpeed(currentVel / context.MovementPhysics.MaxSpeed());
        }
    }
}
