using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDeadState : PlayerState
{
    public PlayerDeadState(SimpleEntityStateMachine context, AttackData data) : base(context) 
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
        context.Animator.SetAnimation("Dead");
        context.Animator.ForceUpdate();
        context.Animator.SetFlipDirection(-attackData.knockbackDirection.x);
        timer = context.Animator.GetCurrentStateDuration() + 3f;
        context.MovementPhysics.Rb.constraints = RigidbodyConstraints2D.FreezeAll;
        context.gameObject.GetComponentInChildren<PlayerTentacles>().enabled = false;
        context.GetComponentInChildren<PlayerActionManager>().enabled = false;
        // do nothing
    }

    public override void ExitState()
    {
        PlayerTentacles.souls += PlayerTentacles.soulsToGet;
        PlayerTentacles.soulsToGet = 0;
        UnityEngine.SceneManagement.SceneManager.LoadScene(UnityEngine.SceneManagement.SceneManager.GetActiveScene().buildIndex);
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
