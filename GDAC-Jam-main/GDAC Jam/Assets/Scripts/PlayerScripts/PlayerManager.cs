using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerManager : MonoBehaviour
{
    [Header("Dependencies")]
    [SerializeField] private SimpleEntityStateMachine playerStateMachine;
    [SerializeField] private InputHandler inputHandler;
    [SerializeField] private MovementPhysicsScript movementPhysics;
    [SerializeField] private AnimationManager animationManager;
    [SerializeField] private BasicEntity entity;
    [SerializeField] private PlayerActionManager actionManager;
    [SerializeField] private Transform playerTransform;

    public Transform PlayerTransform { get => playerTransform;}

    private void Awake()
    {
        inputHandler.Initialize();
        State initialState = new PlayerIdleState(playerStateMachine);
        playerStateMachine.InitializeStateMachine(initialState, entity, animationManager, inputHandler.CurrentInputData, movementPhysics);
        actionManager.Initialize(playerStateMachine);
        entity.Initialize();
    }

}
