using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyRunState : EnemyState
{
    public EnemyRunState(SimpleEntityStateMachine context) : base(context) { }

    public override bool CheckSwitchState()
    {
        if(context.InputData.MovementInput == Vector2.zero)
        {
            SwitchState(new EnemyIdleState(context));
            return true;
        }
        return false;
    }

    public override void EnterState()
    {
        base.EnterState();
        // do nothing
    }

    public override void ExitState()
    {
        base.ExitState();
        // do nothing
    }

    public override void FixedUpdateState()
    {
        Vector2 input = context.InputData.MovementInput.normalized;
        context.MovementPhysics.MoveInDirection(input);
        context.Animator.SetFlipDirection(input.x);
    }

    public override void UpdateState()
    {
        if (CheckSwitchState()) return;
        float currentVel = context.MovementPhysics.RbVel.magnitude;
        bool isStill = currentVel < 0.1f;
        if (isStill)
            context.Animator.SetAnimation("Idle");
        else
            context.Animator.SetAnimation("Run");
    }
}
