using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDashState : PlayerState
{

    public PlayerDashState(SimpleEntityStateMachine context) : base(context) { }

    private float timer = 0f;
    private Vector2 aimDirection;

    public override bool CheckSwitchState()
    {
        if (timer < 0f)
        {
            SwitchState(new PlayerIdleState(context));
            return true;
        }
        return false;
    }

    public override void EnterState()
    {
        base.EnterState();
        Vector2 screenPos = Input.mousePosition;
        Vector3 mousePos = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, 5));
        aimDirection = context.InputData.MovementInput;
        context.MovementPhysics.StopMovement();
        context.Animator.SetAnimation("Dash");
        context.Animator.ForceUpdate();
        context.Animator.SetFlipDirection(aimDirection.x);
        timer = context.Animator.GetCurrentStateDuration();
        context.Entity.SetIFrameDuration(timer);
        context.MovementPhysics.RbVel = aimDirection.normalized * 10f;
    }

    protected override void OnDamaged(AttackData attackData, float currentHealth)
    {
        // do nothing
    }

    public override void ExitState()
    {
        // do nothing
        context.MovementPhysics.StopMovement();
        base.ExitState();
    }

    public override void FixedUpdateState()
    {
        // do nothing
    }

    public override void UpdateState()
    {
        timer -= Time.deltaTime;
        if (CheckSwitchState()) 
            return;
    }
}
