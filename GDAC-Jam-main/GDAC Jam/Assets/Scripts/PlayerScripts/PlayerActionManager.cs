using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerActionManager : MonoBehaviour
{
    private SimpleEntityStateMachine playerStateMachine;
    // Unlocks
    public bool dashUnlocked;

    // Cooldown Timers
    private float dashCooldown;

    public void Initialize(SimpleEntityStateMachine playerStateMachine)
    {
        this.playerStateMachine = playerStateMachine;
    }

    private void Update()
    {
        UpdateTimers();
        if (dashUnlocked && dashCooldown <= 0f && Input.GetKeyDown(KeyCode.Space))
        {
            dashCooldown = 1.3f;
            playerStateMachine.ForceSwitchState(new PlayerDashState(playerStateMachine));
        }
    }

    private void UpdateTimers()
    {
        dashCooldown -= Time.deltaTime;
    }
}
