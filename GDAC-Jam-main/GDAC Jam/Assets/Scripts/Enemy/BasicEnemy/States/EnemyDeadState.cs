using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDeadState : PlayerState
{
    public EnemyDeadState(SimpleEntityStateMachine context, AttackData data) : base(context) 
    {
        attackData = data;
    }

    private AttackData attackData;

    private float timer = 0f;

    public override bool CheckSwitchState()
    {
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
        context.Animator.SetAnimation("Dead");
        context.Animator.ForceUpdate();
        context.Animator.SetFlipDirection(-attackData.knockbackDirection.x);
        timer = context.Animator.GetCurrentStateDuration() + 3f;
        context.GetComponentInChildren<ContactDamage>().gameObject.SetActive(false);
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
        // Add souls
        CheckSwitchState();
        timer -= Time.deltaTime;
        if (timer < 0f)
        {
            // Add stuff
            PlayerTentacles.soulsToGet++;
            GameObject.Destroy(context.Entity.gameObject);
        }
    }
}
